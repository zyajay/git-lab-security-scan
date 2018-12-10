package main

import (
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli"

	"gitlab.com/gitlab-org/security-products/analyzers/common/issue"
	"gitlab.com/gitlab-org/security-products/analyzers/common/orchestrator"
	"gitlab.com/gitlab-org/security-products/analyzers/common/table"

	_ "gitlab.com/gitlab-org/security-products/analyzers/bundler-audit/plugin"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium-maven/plugin"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python/plugin"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/plugin"
	_ "gitlab.com/gitlab-org/security-products/analyzers/retire.js/plugin"

	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/composer"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/gemfile"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/mvnplugin"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/npm"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/pipdeptree"
	_ "gitlab.com/gitlab-org/security-products/analyzers/gemnasium/scanner/parser/yarn"
)

func main() {
	app := cli.NewApp()
	app.Name = "analyzer"
	app.Usage = "Perform Dependency Scanning on given directory (using copy) or on $CI_PROJECT_DIR (mount binding)."
	app.ArgsUsage = "[project-dir]"
	app.Author = "GitLab"

	opts := orchestrator.Options{
		EnvVarPrefix: "DS_",
		ArtifactName: "gl-dependency-scanning-report.json",
		PostWrite:    renderTable,
	}

	app.Flags = orchestrator.MakeFlags(opts)
	app.Action = orchestrator.MakeAction(opts)

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

// renderTable renders the vulnerabilities as a plain text table.
func renderTable(issues []issue.Issue) {
	t := table.New([]int{10, 10, 60})
	t.AppendSeparator()
	t.AppendCells("Severity", "Tool", "Identifier", "URL")
	t.AppendSeparator()
	cveType := issue.IdentifierTypeCVE
	for _, issue := range issues {
		severity := issue.Severity.String()
		tool := issue.Scanner.Name

		// extract CVE id and URL
		var cve, url string
		for _, id := range issue.Identifiers {
			if id.Type == cveType {
				cve = id.Name
				url = id.URL
				break
			}
		}

		// override URL with first link if provided
		if len(issue.Links) > 0 {
			url = issue.Links[0].URL
		}

		// append cells
		t.AppendCells(severity, tool, cve, url)
		t.AppendText("")

		// append body
		if issue.Message != "" {
			t.AppendText(issue.Message)
		}
		if issue.Solution != "" {
			t.AppendText("Solution: " + issue.Solution)
		}
		if filename := issue.Location.File; filename != "" {
			var location string
			if line := issue.Location.LineStart; line != 0 {
				location = fmt.Sprintf("In %s line %d", filename, line)
			} else {
				location = fmt.Sprintf("In %s", filename)
			}
			t.AppendText(location)
		}

		t.AppendSeparator()
	}
	t.Render(os.Stdout)
}
