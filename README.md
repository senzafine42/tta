# Terraform Technical Assignment

## Scenario

### Description
A company is looking to create a proof-of-concept (PoC) environment in a public cloud service provider.  
They want a simple **VPC** and **virtual machines (VMs)** as outlined below.

The company would also like to:
- Use **Terraform** to manage infrastructure as code
- Deploy the solution as a **reusable Terraform module**

### Diagram
> _Diagram to be provided or referenced here_

---

## Deliverables

- Terraform configuration files for the **module**
- Terraform configuration files to deploy the module in a **development environment**
- A `terraform.tfvars` file defining the module’s variables for the environment
- A `tfplan.txt` file containing the output of `terraform plan` with **no errors**
- A **public GitHub repository** or a **git bundle file** containing the solution

---

## What We’re Looking For

- Readable, well-documented Terraform configuration files
- Clear commit history showing your **thought process**
- Your approach to aspects of the assignment that are **not explicitly defined**

You are encouraged to use your preferred best practices and tooling.

---

## Notes

- You may write this module using **any public cloud provider** you are most comfortable with:
  - Google Cloud
  - AWS
  - Azure
- Free-tier usage is sufficient; **you are not required to incur any charges**
- You are **not required to deploy** the solution  
  - Only the `terraform plan` output is required
- If you do deploy resources:
  - Be sure to run `terraform destroy` to avoid accidental charges

---
