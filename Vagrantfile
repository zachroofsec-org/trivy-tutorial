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
        demo.vm.box = "zachroofsec/trivy"
        demo.vm.box_version = "1.0.0"
    end

    # For demo environment (while creating tutorial)
    config.vm.define "demo_inprog", autostart: false do |demo_inprog|
        demo_inprog.vm.box = "kalilinux/rolling"
        demo_inprog.vm.box_version = "2021.1.0"
        demo_inprog.ssh.forward_agent = true
        demo_inprog.vm.provision "shell", path: "install-helpers/prompt-orchestrator.sh"
    end

    # For test environment
    config.vm.define "test", autostart: false do |test|
        test.vm.box = "kalilinux/rolling"
        test.vm.box_version = "2021.1.0"
        test.ssh.forward_agent = true
        test.vm.provision "shell", path: "install-helpers/prompt-orchestrator.sh", privileged: true

#         synced_folder (type: virtualbox) is a 2 way sync.  
#         However, there can be issues with file permissions
#         If there are issues, use `type:"rsync"` (see above)
#         test.vm.synced_folder ".", "/home/vagrant/trivy-tutorial", type:"virtualbox"
    end
end
