# 3Sigma Surveys SFDX Project

This repo holds the code for the 3Sigma Surveys managed package.

The latest version of the packaged contents is available in the `/bin/latest.zip` archive.

An example survey can be found [here](https://x3st-surveys-dev-ed.my.salesforce-sites.com/?srId=a021N00000ZfWeaQAF).

<br />

# Setup

<img src="man/img/Survey-Setup.png" width="49%" style="vertical-align: top;"/>
<img src="man/img/Survey-Question-Setup.png" width="49%" style="vertical-align: top;"/>
<img src="man/img/Survey-Questions.png" width="49%" style="vertical-align: top;"/>

<br />

# Responses

<img src="man/img/Survey-Responses.png" width="49%" style="vertical-align: top;"/>

<img src="man/img/Survey-Response-Detail.png" width="49%" style="vertical-align: top;"/>
<img src="man/img/Survey-Response-Answers.png" width="49%" style="vertical-align: top;"/>

<br />

# Entity Relations

```mermaid
erDiagram
    "Survey" ||..|{ "Survey Question Assignment" : has
    "Survey" ||..|{ "Survey Response" : contains
    "Survey Response" }|..|| "Survey Answer" : has
    "Survey Answer" ||..|| "Survey Question" : has
    "Survey Question Assignment" }o..|| "Survey Question" : has
```