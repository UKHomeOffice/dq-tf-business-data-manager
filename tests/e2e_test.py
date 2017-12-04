# pylint: disable=missing-docstring, line-too-long, protected-access
import unittest
import hashlib
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """
            provider "aws" {
              region = "eu-west-2"
              profile = "foo"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }
            
            module "root_modules" {
              source = "./mymodule"
              providers = {aws = "aws"}
              
            } 
            
        """
        self.result = Runner(self.snippet).result


    # Instance
    @unittest.skip  # @TODO
    def test_instance_user_data(self):
        greenplum_listen = hashlib.sha224("CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_HTTP=0.0.0.0:443").sha1()
        self.assertEqual(self.result["root_modules"]["aws_instance.instance"]["user_data"], greenplum_listen)

    def test_instance_tags_name(self):
        self.assertEqual(self.result["root_modules"]["aws_instance.instance"]["tags.Name"], "instance-bdm-{1}-dq-bdm")

    def test_instance_tags_service(self):
        self.assertEqual(self.result["root_modules"]["aws_instance.instance"]["tags.Service"], "dq-bdm")

    def test_instance_tags_environment(self):
        self.assertEqual(self.result["root_modules"]["aws_instance.instance"]["tags.Environment"], "preprod")

    def test_instance_tags_environmentgroup(self):
        self.assertEqual(self.result["root_modules"]["aws_instance.instance"]["tags.EnvironmentGroup"], "dq-apps")

    # Subnet
    def test_subnet_vpc(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["vpc_id"], "module.apps.appsvpc_id")

    def test_subnet_cidr(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.private_subnet"]["cidr_block"], "10.1.10.0/24")

        @unittest.skip
    def test_web_security_group_ingress(self):
        self.assertTrue(Runner.finder(self.result["root_modules"]["aws_security_group.sgrp"], ingress, {
            'from_port': '443',
            'to_port': '443',
            'Protocol': 'tcp',
            'Cidr_blocks': '10.1.0.0/16'
        }))