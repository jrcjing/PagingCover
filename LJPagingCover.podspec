Pod::Spec.new do |s|
  s.name         = 'LJPagingCover’
  s.version      = '1.0.0'
  s.summary      = "The waterfall (i.e., Pinterest-like) layout for UICollectionView."
  s.homepage     = 'https://github.com/jrcjing/PagingCover'
  s.license      = 'MIT'
  s.author       = { 'Lisa'    => '670306170@qq.com' }
  s.source       = { :git => 'https://github.com/jrcjing/PagingCover.git', :branch => '#{s.version}' }
  s.platform     = :ios, '7.0'
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end
