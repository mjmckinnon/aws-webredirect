## Introduction

<b>aws-webreddirect</b> is a collection of Terraform modules for your AWS account that will provision a collection of objects with the goal of being a permanent place to host and redirect domain names easily.

Some of the objects that are created as part of this web redirection engine include:

* <b>VPC</b> - complete with two subnets in different availability zones, and Internet Gateway and routing table with ACL.
* <b>Application Load Balancer</b> - that will listen on Port 80 (HTTP) and Port 443 (HTTPS)
* <b>Lambda Script</b> - a serverless Python script that can read redirection rules from a CSV file to process how you wish to redirection web requests
* <b>Amazon issued SSL Certificate</b> - it will issue and validate a certificate for valid HTTPS traffic to be served.

### Other Features

* <b>HSTS Enforcement</b> - every HTTP/S response from the lambda script contains a strict-transport-security header designed to enforce use of HTTPS for the domains it is redirecting
* <b>Wildcard Rules</b> - albeit if very basic, the CSV rules file is designed to be as simple as possible with basic wildcard matching also
* <br>Serverless</b> - uses nothing but Lambda to power the web redirection

### Quick Start

First you'll need to install [Terraform](https://terraform.io) and get it working, make sure you understand how it works.

The working directory for doing stuff in here is:

    cd prod

Then you should make a copy of the sample CSV file:

    cp redirections.csv.sample redirections.csv

Next, edit the `main.tf` file and customise the domain near the top, this is a domain name that you will be redelegating and bringing across to AWS, the default zone for your web redirector.

Additional domains must be added by editing the `main.tf` sections with help provided in there.

When you're happy do the usual Terraform things:

     terraform init
     terraform apply

## How the redirections.csv file works

The CSV rule file called `redirections.csv` is very simple and has three columns:

    site_id, request_path, target_url

The `site_id` should always match the base domain name matching where the original request was to - for example, if you were redirecting traffic from `mysite.com` to `example.com` then the `site_id` should be `mysite.com`.

The `request_path` is simply the part after the host that you want to match against, for example `mysite.com/hello-world` would match against `/hello-world`

The `target_url` is simply the location value that will be used for the 301 redirect. It should always be in the the full form, such as `https://example.com/`

### Wildcard Matches

Note you can substitute the `site_id` only once in your rules file with an asterisk (`*`) which will match against any domain name that you don't otherwise have a matching rule for.

You can also use a wildcard (`*`) for the `request_path` only once per unique `site_id` in the rules file which will also act as a catch-all for all requests for a particular site.

If a rule and a wildcard entry do not match the request, the web redirection engine will return a 404 with very simple text response Sorry, that page was not found.

