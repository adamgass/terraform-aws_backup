resource "aws_kms_key" "aws_backup_key" {
  description = "aws backup kms key"
  policy      = <<POLICY
  {
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.AWSBackupRole.arn}"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.AWSBackupRole.arn}"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_kms_alias" "aws_backup_key" {
  name          = "alias/aws-backup-cmk"
  target_key_id = aws_kms_key.aws_backup_key.key_id
}

resource "aws_backup_vault" "backup_vault" {
  name        = var.backup_vault_name
  kms_key_arn = aws_kms_key.aws_backup_key.arn
}

resource "aws_backup_plan" "backup_plan" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_rule_1
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.schedule

    lifecycle {
      delete_after = var.lifecycle_rule
    }
  }
}

resource "aws_iam_role" "AWSBackupRole" {
  name               = "AWSBackupRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "backup.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AWSBackupServiceRolePolicyForBackup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.AWSBackupRole.name
}

resource "aws_iam_role_policy_attachment" "AWSBackupServiceRolePolicyForRestores" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.AWSBackupRole.name
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.AWSBackupRole.arn
  name         = var.backup_selection
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "aws_backup"
    value = var.backup_tag_value
  }
}