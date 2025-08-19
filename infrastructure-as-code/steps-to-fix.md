# Add steps/actions here:

1. step 1: Create State File backup

    **Description**

    This operation creates a backup file of the state file in that we need to revert should anything happen to the state during our configuration change.
    ```
    cp terraform.tfstate terraform.tfstate.backup-file
    ```

2. step 2: Modify the main.tf file utilizing the for_each meta-argument.

    **Description**
    
    The for_each meta-argument will tell terraform to create a resource instance for each unique string in the provided set. This means only four files will be created: file0.txt, file2.txt, file3.txt, and file4.txt.

3. step 3: 

    **Description**

    The source addresses are the old count-based resources and the destination addresses are the new for_each-based resources.

    ```
    terraform state mv 'local_file.foo[0]' 'local_file.foo[\"file0.txt\"]'
    terraform state mv 'local_file.foo[2]' 'local_file.foo[\"file2.txt\"]'
    terraform state mv 'local_file.foo[3]' 'local_file.foo[\"file3.txt\"]'
    terraform state mv 'local_file.foo[4]' 'local_file.foo[\"file4.txt\"]'

    ```

4. step 4: Run Terraform Plan

    ```
    terraform plan -output tfplan-1.json
    ```

5. step 5: Run Terraform Apply

    ```
    terraform apply -auto-approve
    ``` 