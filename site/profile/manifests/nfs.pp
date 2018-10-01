class profile::nfs::client (String $server = "mgmt01") {
  class { '::nfs':
    client_enabled => true,
    nfs_v4_client  => true,
  }
  selinux::boolean { 'use_nfs_home_dirs': }
  nfs::client::mount { '/home':
      server => $server,
      share => 'home'
  }
  nfs::client::mount { '/project':
      server => $server,
      share => 'project'
  }
  nfs::client::mount { '/scratch':
      server => $server,
      share => 'scratch'
  }
  nfs::client::mount { '/etc/slurm':
      server => $server,
      share => 'slurm'
  }  
}

class profile::nfs::server {
  file { ['/project', '/scratch'] :
    ensure  => directory,
    seltype => 'usr_t'
  }

  file { ['/project/6002799', '/project/6002799/photos'] :
    ensure => directory
  }

  file { '/project/6002799/photos/KSC2018.jpg':
    ensure => 'present',
    source => "https://images-assets.nasa.gov/image/KSC-20180316-PH_JBS01_0118/KSC-20180316-PH_JBS01_0118~orig.JPG"
  }

  file { "/project/6002799/photos/VAFB2018.jpg":
    ensure => 'present',
    source => "https://images-assets.nasa.gov/image/VAFB-20180302-PH_ANV01_0056/VAFB-20180302-PH_ANV01_0056~orig.jpg"
  }
  
  class { '::nfs':
    server_enabled => true,
    nfs_v4 => true,
    storeconfigs_enabled => false,
    nfs_v4_export_root  => "/export",
    nfs_v4_export_root_clients => "$cidr(ro,fsid=root,insecure,no_subtree_check,async,root_squash)"
  }

  nfs::server::export{ ['/etc/slurm', '/home', '/project', '/scratch'] :
    ensure  => 'mounted',
    clients => "$cidr(rw,sync,no_root_squash,no_all_squash)"
  }
}