# Manage user SSH authorized keys
# Install public key to user defined by resource name
# Apply for different types of public keys for system users, not encrypted keys
# and for regular users - encrypted keys, distributed separately
#
define ssh::authkey( $key_type ) {
  if $key_type == system {
    ssh_authorized_key { 'root@kasatkin.org':
      user = $name
      type => 'ssh-rsa',
      key  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDjvAvo8meDP9q9QQeyx2n3ULrwby1DofnhNWPHppxNsD8C0JzzBGG/azbro0498h9M+zikCWR12oQLaMTEJwTIx8NsR+1ZMGoN2WilvZ7gk5pCCI5rJTG6KChw4t92gnugyG2Eh2398657c+QNSlkwPpHWdpLmEQrd99YVFRYII0w4Q8lh3sqnTDhrj4aTR8rMIV60NUpU8jqgQjOfZ9nDG6lX7ohraUoGe9Xv9fLUfRHfSsmyAMRDt9rr0sbJV4fV8cQFDVYXgHFBtIRnoz33fxsE4L9RlTWBzTkla3ArjSAWutRSy3TQMlz1mExIqF6ZCtLBuIXNpxrfQlH0Sy6B',
    }
  } else {
    ssh_authorized_key { 'nikolay@kasatkin.org 4096':
      user = $name
      type => 'ssh-rsa',
      key  => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDUilR/STRVYVH9cJ2Dy5jwzSVMKOrfBJhCzxiPW3I5usGqeAGe2kOdUEwABz5W98dqhTIA8NQ+6U2Gb6MfuqvItMPPLRBmVnSNqZQAfOBszgBN7iYOpJlZwEzv+KwD503YvnqUxbH7QrnF9aAKbDebV/iCdHdV7VQOkjsFqKo03mPkoVR+4V4VZVcq1SuIYoYCPRlQbXS3L6vOBHAVwcz8QWzIZartMDUHSwII3kLfbgQxXOatBZQoBhNuOEqLuFXt6tyY+Rox/7vKywYef4e99RNLXNOP9ir6iPi5WYW19BDBaQdRbAZr52/GZsVa1aPZmI8lQC6fb/rVU/UCjY4iziNf5JRG9L0kKKz/uSmcPMBNcdV7TjcVJ4QHgxPyXnVCR4WWeNT3D3NBYV255Ckx63753eQAKbO5H7LTJEB79MapLsWW7Bch3/VcxGLBPI37If5b1pGbKczBEarmvPKrx8xBygzzu9jRhhVX9/Ot107XQ10o5XZ+OHF0bdE6Z6T6ZtVLcL+QBkm2Vq+ZhojSMRmfvrq70o9eOyn6VrvuAIN3/EsruXyA2OVPcUKpkSrP7OKJSelRpwkkgj8XuzgBTZf79ayZDT8b7877S+f4qEB24bfXUYBWZKk7HSbTJxLxW1qTg9Z1L+u9kxIkBssntaab+09QkqMdjyiFfhkTAQ==',
    }
  }
}

