# macOS Setup Script

# Helper function
go_next() {
    echo "Do you want to continue to the next step?"
    echo "Select an option then Enter (y -> Continue, q -> Quit)"
#    echo "y: Continue"
#    echo "q: Quit program"
#    printf "Press \"y\" then Enter to continue. Or \"q\" then Enter to quit: "
#    echo ""
    printf "Option: "
    read -r input
    while [ "$input" != "y" ] && [ "$input" != "q" ]
    do
        printf "Option: "
        read -r input
    done
    
    if [ "$input" == "q" ]; then
        echo "Quitting..."
        exit    
    fi
}

ask_for_update() {
    echo "Do you want to update?"
    echo "Select an option then Enter (y -> Yes, n -> No)"
#    echo ""

}

thanks() {
    echo ""
    echo "All completed."
    echo "Thank you for using the script. Have a nice day! :)"
}

install_brew() {
    echo "----------------------"
    echo "1. Homebrew"
    if test ! $(which brew); then
      echo "Homebrew's not installed. Installing homebrew..."
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Homebrew's installed."
        echo $(brew -v)
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating homebrew..."
            brew update
        fi
        echo ""
    fi


}

config_gem() {
    echo 'export GEM_HOME="$HOME/.gem"' >> ~/.bash_profile
    echo 'export PATH="$GEM_HOME/bin:$PATH"' >> ~/.zshrc
    
    source ~/.zshrc
    source ~/.bash_profile
}

install_rvm() {
    echo "----------------------"
    echo "2. RVM + Ruby"
    
    
    if brew list gnupg &>/dev/null; then
        printf ""
    else
        brew install gnupg
        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

    fi
    
    # 2.1 RVM
    echo "Checking rvm"
    if test ! $(which rvm); then
        echo "rvm's not installed. Installing rvm..."
        \curl -sSL https://get.rvm.io | bash
        source ~/.rvm/scripts/rvm
    else
        echo "rvm's version:"
        echo $(rvm -v)
        echo ""
        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating rvm..."
            gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
            rvm get stable
        fi
        echo ""
    fi
    

    
    # 2.2 Ruby
    echo "Checking ruby 2.6.8"
    list=$(rvm list)
    if echo "$list" | grep -q "2.6.8"; then
        echo "ruby 2.6.8 found."
    else
        echo "ruby 2.6.8 not found."
        echo "Installing ruby 2.6.8..."
        rvm install 2.6.8
    fi
    
    #Add gem to PATH to preventing permission issue.
    config_gem
    
    echo ""
}

install_xcode() {
    echo "----------------------"
    echo "3. Xcode + Command line tool"
    # Check if Xcode existed.
    
    # 3.1 Xcode
    if test ! $(which xcodebuild); then
        echo "Xcode's not installed. Installing Xcode..."
        echo "You can visit https://xcodereleases.com to view all version."
        go_next
    else
        echo "Xcode's installed."
        echo $(xcodebuild -version)
    fi
    echo ""
    
    # 3.2 Command line tool
    if test ! $(which xcode-select); then
        echo "Command line tool's not installed. Installing Command line tool..."
        xcode-select --install
        
        echo "Pointing Command line tool to Xcode directory..."
        echo "This command requires sudo so please enter your password."
        
        if echo "$(ls /Applications)" | grep -q "Xcode"; then
            sudo xcode-select -s "$(xcode-select --print-path)"
        fi
        
        go_next
    else
        echo "Command line tool's installed."
        xcode-select -version
    fi
    echo ""
}

install_jdk() {
    echo "----------------------"
    echo "4. JDK"
    
    if brew list java &>/dev/null; then
        echo "JDK's installed."
        java -version
        echo ""
        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating JDK..."
            brew upgrade java
        fi
        echo ""
    else
        echo "JDK's not installed. Installing JDK..."
        brew install java

        echo "Setting JAVA_HOME"
        echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.bash_profile
        echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc
        
        echo $"\nexport JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/\n" >> ~/.zshrc
        echo $"\nexport JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/\n" >> ~/.bash_profile
        echo 'export JAVA_HOME="\$(/usr/libexec/java_home)"' >> ~/.bash_profile
        echo 'export JAVA_HOME="\$(/usr/libexec/java_home)"' >> ~/.zshrc
        
        source ~/.bash_profile
        source ~/.zshrc
        
        echo "JAVA_HOME"
        echo "$JAVA_HOME"
        
        echo "Creating a symbolic link for JDK."
        sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    fi
    
    echo "JAVA_HOME"
    echo "$JAVA_HOME"

    echo ""
}

install_android() {
    echo "----------------------"
    echo "5. Android Studio"
    
    if echo "$(ls /Applications)" | grep -q "Android Studio"; then
        echo "Android Studio's installed."
    else
        echo "Android Studio's not installed. Installing Android Studio..."
        echo ""
        go_next
        # echo "Installing Android JDK..."
        # echo "android-sdk requires Java 8"
        # brew install --cask homebrew/cask-versions/adoptopenjdk8
        # echo $"\nexport JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/\n" >> /Users/$(whoami)/.zshrc
        # source ~/.zshrc

        # brew install --cask android-platform-tools
        # brew install android-sdk
                
        echo "Setting ANDROID_HOME"
        echo 'export "ANDROID_HOME=$HOME/Library/Andorid/sdk"' >> ~/.bash_profile
        echo 'export "PATH=$ANDROID_HOME/tools:$PATH"' >> ~/.bash_profile
        # echo 'export "PATH=$ANDROID_HOME/platform-tools:$PATH"' >> ~/.bash_profile
        source ~/.bash_profile

        echo 'export "ANDROID_HOME=$HOME/Library/Andorid/sdk"' >> ~/.zshrc
        echo 'export "PATH=$ANDROID_HOME/tools:$PATH"' >> ~/.zshrc
        # echo 'export "PATH=$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
        source ~/.zshrc
        
        
    fi
    
    echo "ANDROID_HOME"
    echo "$ANDROID_HOME"
    echo ""

}

install_npm() {
    echo "----------------------"
    echo "6. npm + node"
    
    # 6.1 Install node
    if brew list node &>/dev/null; then
        # check for update?
        echo "npm's installed."
        echo $(npm -version)
        echo "node's installed."
        echo $(node -v)
        echo ""
        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating npm and node..."
            brew upgrade node
        fi
        echo ""

    else
        echo "npm's not installed. Installing npm and node latest version..."
        brew install node
    fi
}

install_iosdeploy() {
    echo "----------------------"
    echo "7. iOS-deploy"

    if test ! $(which ios-deploy); then
        echo "ios-deploy's not installed. Installing ios-deploy..."
        npm install -g ios-deploy
    else
        echo "ios-deploy's installed."
        ios-deploy -V
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating ios-deploy..."
            npm update ios-deploy
        fi
        echo ""
    fi

}

install_chrome_driver() {
    echo "----------------------"
    echo "8. Chrome driver"
    
    #
    if test ! $(which chromedriver); then
        echo "chromedriver's not installed. Installing chromedriver..."
        brew install chromedriver
    else
        echo "chromedriver's installed."
        chromedriver -v
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating chromedriver..."
            brew upgrade chromedriver
        fi
        echo ""
    fi
}

install_bundler() {
    echo "----------------------"
    echo "9. bundler"
    
    if test ! $(which bundler); then
        echo "bundler's not installed. Installing bundler..."
        gem install bundler
    else
        echo "bundler's installed."
        bundler -v
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating bundler..."
            gem update bundler
        fi
        echo ""
    fi
}

install_calabash_cucumber() {
    echo "----------------------"
    echo "11. calabash-cucumber"
    
    #
    if test ! $(which calabash-ios); then
        echo "calabash-cucumber's not installed. Installing calabash-cucumber..."
        gem install calabash-cucumber
        calabash-ios version
    else
        echo "calabash-cucumber's installed."
        calabash-ios version
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating calabash-cucumber..."
            gem update calabash-cucumber
        fi
        echo ""
    fi
}
    
install_keystone() {
#    echo "----------------------"
#    echo "x. calabash-android"
    
    if test ! $(which calabash-android); then
        echo "calabash-android's not installed. Installing calabash-android..."
        gem install calabash-android
    else
        echo "calabash-android's installed."
        calabash-android version
        echo ""

        ask_for_update
        printf "Option: "
        read -r input
        while [ "$input" != "y" ] && [ "$input" != "n" ]
        do
            printf "Option: "
            read -r input
        done
        if [ "$input" == "y" ]; then
            echo "Updating calabash-android..."
            gem update calabash-android
        fi
        echo ""
    fi
}

create_keystone() {
    echo "----------------------"
    echo "10. calabash-android setup"
    install_keystone
    
    yes | calabash-android setup
    location=$'{"keystore_location":"~/.android/debug.keystore","keystore_password":"","keystore_alias":""}'
    echo ""
    echo "Setting the keystore location to ~/.android/debug.keystore"
    echo "$location" >> .calabash_settings
    
}

# MAIN

install_brew
go_next
install_rvm
go_next
install_xcode
go_next
install_jdk
go_next
install_android
go_next
install_npm
go_next
install_iosdeploy
go_next
install_chrome_driver
go_next
install_bundler
go_next
create_keystone
go_next
install_calabash_cucumber
thanks
