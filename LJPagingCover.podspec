Pod::Spec.new do |s|
  s.name         = 'LJPagingCover'
  s.version      = '1.0.0'
  s.summary      = "The paging cover layout for UIScrollView."
  s.homepage     = 'https://github.com/jrcjing/PagingCover'
  s.license      = "Copyright (c) 2015年 Lisa. All rights reserved."
  s.author       = { 'Lisa'    => '670306170@qq.com' }
  s.source       = { :git => 'https://github.com/jrcjing/PagingCover.git', :tag => '1.0.0' }
  s.platform     = :ios, '7.0'
  s.source_files = '*.{h,m}', 'LJPagingCover/*.{h,m}'
  s.requires_arc = true
end
