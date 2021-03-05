Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "5192"
    end

    # If we don't use rsync, vagrant will mount the shared folder as root
    # (this can cause file permission errors)
    # To automate the 1 way sync: `vagrant auto-sync VM_NAME`
    config.vm.synced_folder ".", "/home/vagrant/trivy-tutorial", type:"rsync", owner: "vagrant", group: "vagrant"

    # For "final" demo environment that learner will use
    config.vm.define "demo", primary: true do |demo|
        config.vm.box = "zachroofsec/trivy"
        config.vm.box_version = "1.0.0"
    end

    # For demo environment (while creating tutorial)
    config.vm.define "demo-inprog", autostart: false do |demo|
        config.vm.box = "kalilinux/rolling"
        config.vm.box_version = "2021.1.0"
        config.ssh.forward_agent = true
    end

    # For test environment
    config.vm.define "test", autostart: false do |test|
        config.vm.box = "kalilinux/rolling"
        config.vm.box_version = "2021.1.0"
        config.ssh.forward_agent = true

        # Virtualbox synced_folder is a 2 way sync.  However, there can be issues with file permissions
        # If there are issues, use `type:"rsync"` (see above)
        config.vm.synced_folder ".", "/home/vagrant/trivy-tutorial", type:"virtualbox"
    end
end
