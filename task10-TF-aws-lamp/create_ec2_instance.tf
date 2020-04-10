provider "aws" {
  region                 = var.region_run
 }


resource "aws_instance" "web1" {
  ami                     = var.ami
  instance_type           = var.size_instance

  iam_instance_profile        = aws_iam_instance_profile.s3_read_profile.name
  vpc_security_group_ids      = [aws_security_group.my_web.id]
  subnet_id                   = aws_subnet.eu-central-1a-public.id
  associate_public_ip_address = true
  depends_on                  = [aws_instance.db]
  key_name                    = var.keypair
 
  
  tags = {
    Name    = "Web1"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task10"
  }
  user_data = file("user_data.sh")
  
  provisioner "remote-exec" { #install apache, mysql client, php
  inline = [

      "sudo mkdir -p  /var/www/html"
   ]
  }

  
  provisioner "file" {
        content     = <<EOT
<?php
$DB_host = "${aws_instance.db.public_ip}";
$DB_user = "dbpdo";
$DB_pass = "dbpdo";
$DB_name = "dbpdo";

try
{
	$DB_con = new PDO("mysql:host={$DB_host};dbname={$DB_name}",$DB_user,$DB_pass);
	$DB_con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
catch(PDOException $e)
{
	echo $e->getMessage();
}
include_once 'class.crud.php';
$crud = new crud($DB_con);
?>
                        EOT
        destination = "/tmp/dbconfig.php"
    }
  provisioner "remote-exec" { #install apache, mysql client, php
  inline = [
    
      "sudo cp /tmp/dbconfig.php /var/www/html/dbconfig.php"

   ]
  }
  connection {
    type     = "ssh"
    user     = var.user_name
    host     = self.public_ip
    #copy <private.pem> to your local instance to the home directory
    #chmod 600 id_rsa.pem
    private_key = file("jenkins.pem")


}
}

# resource "aws_instance" "web2" {
#  ami                     = var.ami
#  instance_type           = var.size_instance
#  iam_instance_profile   = aws_iam_instance_profile.s3_read_profile.name
#  vpc_security_group_ids = [aws_security_group.my_web2.id]
#  subnet_id              = aws_subnet.eu-central-1a-public-second.id
#  associate_public_ip_address = true
#  depends_on = [aws_instance.db]
#  key_name               = var.keypair

#  tags = {
#    Name    = "Web2"
#    Owner   = "Kozulenko Volodymyr"
#    Project = "Terraform AWS task10"
#  }
#  user_data = file("user_data.sh")
#  
#}

resource "aws_instance" "db" {
  ami                     = var.ami
  instance_type           = var.size_instance

  iam_instance_profile   = aws_iam_instance_profile.s3_read_profile.name
  vpc_security_group_ids = [aws_security_group.db.id]
# subnet_id              = aws_subnet.eu-central-1a-private.id
  subnet_id              = aws_subnet.eu-central-1a-public.id
  associate_public_ip_address = true
  key_name                = var.keypair
  tags = {
    Name    = "DB"
    Owner   = "Kozulenko Volodymyr"
    Project = "Terraform AWS task10"
  }
  user_data = file("user_data_db.sh")

}

