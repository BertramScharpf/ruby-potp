# The Plain One Time Password Library

A ruby library for generating and validating one time passwords (HOTP & TOTP)
according to
[RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226)
and
[RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238).

POTP aims to be compatible with
[Google Authenticator](https://github.com/google/google-authenticator).

The Base32 format conforms to
[RFC 4648 Base32](http://en.wikipedia.org/wiki/Base32#Base_32_Encoding_per_§6)


## Installation

```bash
sudo gem install potp
```

If you like to run the executable (instead of writing a one-liner for
yourself), you have to install the `appl` gem.

```bash
sudo gem install appl
```


## Library Usage

### Time based (TOTP)

```ruby
require "potp"

totp = POTP::TOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
totp.now  #=> "152201"

totp.verify "152201"  #=> 1735417500     # ok, value is the timestamp
sleep 30
totp.verify "152201"  #=> nil            # not ok
```

### Counter based (HOTP)

```ruby
hotp = POTP::HOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
hotp.at  0  #=> "178748"
hotp.at  1  #=> "584373"
hotp.at 73  #=> "309764"

# OTP verifying with a counter
hotp.verify "309764", 73              #=> 73
hotp.verify "309764", 74              #=> nil
hotp.verify "309764", 70, retries: 2  #=> nil
hotp.verify "309764", 70, retries: 3  #=> 73
```


### Avoiding reuse of TOTP

```ruby
require "potp"
totp = POTP::TOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
code = totp.now                       #=> "054626"
last_verify = totp.verify code        #=> 1735527390
totp.verify code, after: last_verify  #=> nil
sleep 30
code = totp.now                       #=> "481150"
totp.verify code, after: last_verify  #=> 1735527420
```


### Verifying a TOTP with drift

In case a user entered a code just after it has expired, you can allow
the token to remain valid.

```ruby
totp = POTP::TOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
now = Time.now - 30
code = totp.at now                 #=> "455335"
totp.verify code                   #=> nil
totp.verify code, drift_behind: 27 #=> 1735530510
```


### Generating a Base32 secret key

Returns a 160 bit (32 character) Base32 secret.

```ruby
require "potp/random"
POTP::Base32.random  #=> "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
```


### Generating QR codes for provisioning mobile apps

```ruby
require "potp"

totp = POTP::TOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
uri = totp.provisioning_uri name: "jdoe@example.net", issuer: "ACME Service"
#=> "otpauth://totp/ACME%20Service:jdoe%40example.net?secret=GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A&issuer=ACME%20Service"

hotp = POTP::HOTP.new "GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A"
uri = hotp.provisioning_uri name: "jdoe@example.net", issuer: "ACME Service", counter: 0
#=> "otpauth://hotp/ACME%20Service:jdoe%40example.net?secret=GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A&issuer=ACME%20Service&counter=0"

# Then, do something like this:
system *%w(qrencode -t xpm -s 1 -o), "qr.xpm", uri
```


## Executable Usage

Generates a time-based one-time password:

```bash
potp --secret GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A
```

Generates a counter-based one-time password:

```bash
potp --hmac --secret GYS5L3N3E4AAYNMN562LW76TMWHQBJ4A --counter 42
```

What you expect:

```bash
potp --help
```


## Copyright

  * (C) 2025 Bertram Scharpf <software@bertram-scharpf.de>
  * License: [BSD-2-Clause+](./LICENSE)

