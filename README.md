# License Server on Pouta

OpenStack and Ansible scripts for hosting a private MATLAB license server on [CSC Pouta](https://pouta.csc.fi/).
Hosting other FlexLM licenses should work in similar way.

This setup creates the following infrastructure on Pouta:

- A virtual machine running Ubuntu
- A floating IP address for external access
- SSH key pair for secure access
- Configured MATLAB license server software

## Setup Instructions

### 1. Configure OpenStack Environment

Follow the [CSC Pouta documentation](https://docs.csc.fi/cloud/pouta/install-client/#configure-your-terminal-environment-for-openstack) to set up your terminal environment.

Source your project credentials:

```bash
. <project_name_here>-openrc.sh
```

This loads your OpenStack credentials into the current shell session.

### 2. Install Dependencies

Create a Python virtual environment and install required tools.

Regular pip:

```bash
python3 -m venv
. .venv/bin/activate
pip install -r requirements.txt
```

Using `uv`:

```bash
uv venv --python 3.12
. .venv/bin/activate
uv pip install -r requirements.txt
```

This installs Ansible and the OpenStack SDK.

### 3. Create SSH Key

Generate an SSH key pair for accessing the VM:

```bash
./01_create_ssh_key.sh
```

The key is saved as `~/.ssh/id_rsa_license_server`.

### 4. Create the Virtual Machine

Deploy the VM using OpenStack Heat with CIRDs for allowed SSH connections as comma separated list:

```bash
./02_create_vm.sh "0.0.0.0/32,0.0.0.0/32"
```

Verify the stack was created successfully:

```bash
openstack stack show license-server -f json
```

To retrieve the floating IP address assigned to your VM:

```bash
openstack stack show license-server -f json | jq -r '.outputs[] | select(.output_key=="floating_ip_address") | .output_value'
```

### 5. Configure the License Server

Run Ansible to install and configure MATLAB license server software:

```bash
./03_configure_vm.sh
```

This script connects to the VM and sets up the license server components.

### 6. Activate MATLAB License

After the configuration completes, you need to activate your MATLAB license:

1. SSH into the VM to get the host ID:
   ```bash
   ssh -i ~/.ssh/id_rsa_license_server ubuntu@<floating-ip>
   ```

   Print the hostid and copy it:

   ```bash
   /license/matlab/mlm/R2025b/lm_matlab.sh hostid
   ```

2. Go to the [MATLAB License Center](https://www.mathworks.com/licensecenter/)

3. Activate your license:
   - Select "Activate a License Server"
   - Choose "Linux" as the operating system
   - Enter the VM's host ID
   - Provide a label

4. Download the license file.

5. On the server, append the license contents to the license file on the server:

   ```bash
   sudo -u lmmatlab vi /license/matlab/license.lic
   ```

## Usage

Once the license server is running, configure MATLAB clients to use it:

```bash
export MLM_LICENSE_FILE=27000@<floating-ip>
```

Replace `<floating-ip>` with the actual floating IP address of your license server.
