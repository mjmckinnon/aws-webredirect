# Lambda script - Web Redirector
# https://github.com/mjmckinnon/aws-webredirect

import csv
import re


def getBaseSite(host):
    """Take a host header and return it without www."""
    return re.sub("^www.", "", host.lower(), 1)


def getTargetPage(site_id, event_path):
    """Lookup SITE and PATH to get TARGET"""
    default_target = None
    global_target = None
    request_path = event_path.lower()
    with open("redirections.csv") as csv_file:
        fieldnames = ("site_id", "request_path", "target_url")
        csv_reader = csv.DictReader(csv_file, fieldnames=fieldnames)
        for row in csv_reader:
            # find the master_default_target (with *,*)
            if row["site_id"] == "*" and row["request_path"] == "*":
                global_target = row["target_url"]
            else:
                # must match site_id
                if row["site_id"] == site_id:
                    # put a pin in the default (*) redirection
                    if row["request_path"] == "*":
                        default_target = row["target_url"]
                    # return if we have a match (normal)
                    redirect_path = row["request_path"].lower()
                    if request_path == redirect_path or re.sub("\/$", "", request_path, 1) == redirect_path:
                        return row["target_url"]
        if default_target is not None:
            # We didn't find a direct match, but there is a default for this site
            return default_target  # return the default target (one with '*')
        else:
            # No match for site or page, so fallback to global default
            return global_target  # return override default (one with '*,*')


def web_handler(event, context):
    # Find which host and get target
    site = getBaseSite(event["headers"]["host"])
    # Get the target page for redirection
    target_url = getTargetPage(site, event["path"])
    if target_url is not None:
        return {
            "statusCode": 301,
            "headers": {
                "Strict-Transport-Security": "max-age=31536000",
                "Location": target_url
            }
        }
    else:
        return {
            "statusCode": 404,
            "headers": {
                "Strict-Transport-Security": "max-age=31536000",
                "Content-Type": "text/html"
            },
            "body": "Sorry, that page was not found."
        }
