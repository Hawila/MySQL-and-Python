
resource "aws_ecrpublic_repository" "flask_repo" {
  repository_name = "flask-webapp"


  
}

resource "aws_ecrpublic_repository" "mysql_repo" {
  repository_name = "mysqldb"

 
}