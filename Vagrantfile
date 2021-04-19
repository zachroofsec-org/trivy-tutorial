Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "5192"
    end
    
    course = Pathname.new(__FILE__).dirname.basename
    vm_course_path = "/home/vagrant/#{course}"
    
    # Defaults
    config.vm.box = "kalilinux/rolling"
    config.vm.box_version = "2021.1.0"
    config.ssh.forward_agent = true
    config.vm.synced_folder ".", vm_course_path, type:"virtualbox"
    # Must use "inline" to set correct paths within scripts
    # https://stackoverflow.com/a/56575381
    config.vm.provision "install-prompt", type: "shell", inline: "#{vm_course_path}/install-helpers/prompt-orchestrator.sh", privileged: true
    config.vm.provision "install-#{course}", type: "shell", inline: "#{vm_course_path}/install.sh", privileged: false, reboot: true

    # For "final" demo environment that learner will use
    config.vm.define "demo-#{course}", primary: true do |demo|
        demo.vm.box = "zachroofsec/#{course}"
        demo.vm.box_version = "1.0.0"
        # Override defaults for installation
        demo.vm.provision "install-#{course}", type: "shell", inline: "echo 'Course artifacts already installed!'" 
    end
    
    # For publishing demo environment 
    config.vm.define "demo-publish-#{course}", autostart: false do |demo_publish|
        demo_publish.ssh.forward_agent = false
        demo_publish.vm.synced_folder ".", "#{vm_course_path}", type: "rsync",
            rsync__exclude: [".git/", ".vagrant/"]
    end
    
    # For demo environment (while creating course)
    config.vm.define "demo-inprog-#{course}", autostart: false do |demo_inprog|
    end

    # Sandbox environment (for iterating before course creation)
    config.vm.define "test-#{course}", autostart: false do |test|
    end
end
