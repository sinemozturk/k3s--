output "master_ip" {
  value = aws_instance.k3s_master.public_ip
}

output "worker_ips" {
  value = [for instance in aws_instance.k3s_workers : instance.public_ip]
}

output "ansible_inventory" {
  value = <<EOF
[masters]
master ansible_host=${aws_instance.k3s_master.public_ip} ansible_user=ec2-user

[workers]
%{ for ip in aws_instance.k3s_workers[*].public_ip ~}
worker ansible_host=${ip} ansible_user=ec2-user
%{ endfor ~}
EOF
}

output "private_key" {
  value     = tls_private_key.k3s_key.private_key_pem
  sensitive = true
}
