Blogging platform
=================

This repo uses Terraform to create a Wordpress ElasticBeanstalk app on AWS.
It will create a VPC (and all associate networking components), Mysql RDS instance, Bastion host, and an Elastic Beanstalk Env running 2 web servers.

Scaling
--------
I chose Elastic Beanstalk because it is rasy to scale, you have the option of both increasing the instance size (since it's a t2.micro right now) and adding more web app servers to share the load. 
 Right now the autoscaling group is set to 2 Min&Max but it's easy to change with terraform, you can also add cloudwatch monitoring and use preformance and networking tresholds to automatically change the number of running instances.
The database can also be scaled up and it's also possible to create a cluster with several slaves that will also serve read requests.
Another thing that can be done to improve performance is adding a caching layer (like varnish) or an external CDN provider, which will reduce the number of queries that hit the website.

Caveats
--------
Elastic Beanstalk:
-----------------

The Elastic Beanstalk module will create a Beanstalk app, environment and an app version but it will not deploy the app version (Terraform doesn't support that atm), it's possible to run Terraform from a wrapper script and add an Elastic Beanstalk deployment to the initial run; but I wouldn't want my infrastructure code to also deploy the application. Instead I will have my CI/CD tool that builds the application code deploy the appropriate version to an S3 bucket and to the environment I created - this way any version update is independent from the infra code and there is no risk of accidentally overwriting a running environment when preforming an infrastructure change.

Wordpress:
---------

The code I wrote will deploy a Wordpress website and all required dependencies but it will not initialise the wordpress website.
Wordpress is a CMS, it stores posts and all sorts of metadata in a DB and images and template on a the server itself - the only way I could think of pre populating the content was creating it manually, dumping the sql and copying the website and then using the website copy as the base Wordpress code and restoring the DB as part of the Terraform run (I guess you can add a shell provisioner to the Bastion module and use it to install mysql and populate the DB from there) but that seemed like an overkill, so I manually (with shame and sadness) created my first and last Wordpress blog (I should have use a static page).

Sorry for the wall of text and thank you for making it this far :)
Keren
