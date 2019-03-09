provider "aws" {
   region  = "${var.region}"
}

data "aws_ami" "centos7" {
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = ["679593333241"]
  filter {
    name   = "description"
    values = ["CentOS Linux 7*"]
  }

  most_recent = true
}

resource "aws_instance" "cs7" {
	 ami = "${data.aws_ami.centos7.image_id}"
	 instance_type = "t2.micro"

	 root_block_device {
	     delete_on_termination = true
	     volume_type = "standard"
	 }
	 security_groups = ["sg_jenk"]
	 key_name = "vpkey"
	 provisioner "local-exec" {
	     command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u centos c7.yml"
	 }
}

resource "aws_security_group" "sg_jenk" {
	 name = "sg_jenk"
	 description = "Allow port for jenkins"
	 ingress{
	    from_port   = 443
	    to_port     = 443
    	    protocol    = "tcp"
    	    # Please restrict your ingress to only necessary IPs and ports.
    	    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    	    cidr_blocks	= ["0.0.0.0/0"] # add your IP address here
  	 }
	 ingress{
	    from_port   = 80
	    to_port     = 80
    	    protocol    = "tcp"
    	    # Please restrict your ingress to only necessary IPs and ports.
    	    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    	    cidr_blocks	= ["0.0.0.0/0"] # add your IP address here
  	 }
	 ingress{
	    from_port   = 22
	    to_port     = 22
    	    protocol    = "tcp"
    	    # Please restrict your ingress to only necessary IPs and ports.
    	    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    	    cidr_blocks	= ["0.0.0.0/0"] # add your IP address here
  	  }
    	  egress {
          	 from_port = 0
	      	 to_port   = 0
	         protocol     = "-1"
		 cidr_blocks = ["0.0.0.0/0"]
	  }
			      
}

resource "aws_key_pair" "vpkey" {
	 key_name = "vpkey"
	 public_key = "${file("~/.ssh/id_rsa.pub")}"
}


output "ip_of_instance" {
       value = "${aws_instance.cs7.public_ip}"
}