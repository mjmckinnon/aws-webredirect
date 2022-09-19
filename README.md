## Introduction

<b>aws-webreddirect</b> is a collection of Terraform modules for your AWS account that will provision a collection of objects with the goal of being a permanent place to host and redirect domain names easily.

Some of the objects that are created as part of this web redirection engine include:

* <b>VPC</b> - complete with two subnets in different availability zones, an Internet Gateway and routing table with ACL.
* <b>Application Load Balancer</b> - that will listen on Port 80 (HTTP) and Port 443 (HTTPS)
* <b>Lambda Script</b> - a serverless Python script that can read redirection rules from a CSV file (that you create) to process web requests
* <b>Amazon issued SSL Certificates</b> - it will issue and validate a certificate for valid HTTPS traffic to be served and redirected

### Other Features

* <b>HSTS Enforcement</b> - every HTTP/S response from the lambda script contains a strict-transport-security header designed to enforce the use of HTTPS for the domains it is redirecting
* <b>Wildcard Rules</b> - albeit it somewhat basic, the CSV rules file is designed to be as simple as possible with some wildcard matching also
* <br>Serverless</b> - uses nothing but Lambda to power the web redirection, and you get up to 1 Million free requests each month from AWS

### Quick Start

First you'll need to install [Terraform](https://terraform.io) and get it working, make sure you understand how it works.

The working directory for doing everything in here is:

    git clone https://github.com/mjmckinnon/aws-webredirect.git
    cd aws-webredirect/prod

You should initialise the terraform modules, and create some static nameservers:

    terraform init
    terraform apply --target aws_route53_delegation_set.nameservers

You should see a list of four nameservers from AWS appear in the output - make a note of them!

Then you should make a copy of the sample CSV file and edit accordingly:

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

## Order of operations

When you add a domain, you will typically edit the `main.tf` (or other custom) file and add two sections such as:

    resource "aws_route53_zone" "MYDOMAIN-COM" {
        name = "mydomain.com"
        delegation_site_id = aws_route53_delegation_set.nameservers.id
    }

    module "MYDOMAIN-COM" {
        source = "../modules/webredir-zone"
        zone_id = aws_route53_zone.MYDOMAIN-COM.zone_id
        loadbalancer_arn = module.webredirengine.loadbalancer_arn
        https_listener_arn = module.webredirengine.https_listener_arn
    }

Note the "MYDOMAIN-COM" which would be your unique variable to reference the domain (needed when adding lots of domains to this system). It will mean that zone will be referenced in Terraform as something like: `aws_route53_zone.mydomain-com`.

You may also want to manage other DNS records for these domains with additional records, such as:

    resource "aws_route53_record" "WWW-MYDOMAIN-COM-A" {
        aws_route53_zone.MYDOMAIN-COM.zone_id
        name = "www.mydomain.com"
        type = "A"
        ttl = 3600
        records = [
            "127.0.0.1"
        ]
    }

Read up on Terraform to take advantage of infrastructure and DNS configuration as code!

Here is an example of the correct order of operations for using this web redirection engine:

1. Always work from the `prod/` folder, no need to edit any files in the modules path.
1. Edit the `prod/main.tf` file and add your domain to it, or group domains into separate `.tf` files in the same path.
1. Don't forget to create your own `redirections.csv` file (copy from the sample) and add rules (see above about `site_id` and syntax of that file)
1. Validate the terraform code with `terraform validate` and correct any syntax errors.
1. Whenever you add a new `module` reference you must also initialise it, with `terraform init` (always from the prod folder)
1. Before proceeding further, you MUST redelegate the live domain name(s) you're setting up to the AWS nameservers you took note of in the Getting Started.
1. You might need to wait a little while to ensure DNS propagates [here is a useful site](https://www.whatsmydns.net) to check that.
1. Now it's time for the magic! Run `terraform apply` and carefully check what actions it will do, pay atttention to any deletions/updates.
1. If you get any errors simply try to run `terraform apply` again, and if it persists file an issue here and let me know!

Congratulations! Your live production domain(s) should now be accepting HTTP/S requests and redirecting according to your CSV file.
