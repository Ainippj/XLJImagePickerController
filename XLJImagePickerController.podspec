

Pod::Spec.new do |s|

  s.name         = "XLJImagePickerController"
  s.version      = "1.0.0"
  s.summary      = "图片选择器"

  s.description  = <<-DESC
       XLJImagePickerController
                   DESC
  s.homepage     = "https://github.com/Ainippj/XLJImagePickerController"

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "xuelijun" => "1342389838@qq.com" }


   s.ios.deployment_target = "8.0"


  s.source       = { :git => "https://github.com/Ainippj/XLJImagePickerController.git", :tag => s.version }

    s.source_files = "XLJImagePickerController/Headers/*.h"

    s.subspec 'UIKit' do |uikit|
        uikit.source_files  = "XLJImagePickerController/*.{h,m}"
    end

  s.resources = 'XLJImagePickerController/*.{png,bundle}'
  s.resource_bundles = {
      'XibReSource' => ['XLJImagePickerController/*.xib'],
  }

  s.frameworks = "MobileCoreServices"

  s.requires_arc = true
  s.dependency 'MBProgressHUD'
  

end
