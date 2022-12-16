---
title: "Rust(lettre)とさくらのメールボックスでメール送信"
author: ["Yudai Fukushima"]
date: 2021-06-01
lastmod: 2021-06-01
categories: ["Rust"]
draft: false
description: "Rust lettre & さくらメールボックス"
math: true
menu:
 sidebar:
   name: Rust lettre
   identifier: rust-lettre
   parent: develop-jp
   weight: 10
---

## はじめに {#はじめに}

Rust の lettre クレートでさくらのメールボックスを用いて独自ドメインでのメールを送信する際の記録です。 <br/>

前提としては、 <br/>

-   xdomain にて独自ドメインを取得済み <br/>
-   Netlify DNS にネームサーバを設定してる <br/>
    
    独自ドメインのメールアドレスでメールの送信がしたいが、ネームサーバは変更したくないというような状態です。 <br/>


## [lettre](https://github.com/lettre/lettre) {#lettre}

Rust のメーラライブラリで、 <br/>

-   SMTP(Simple Mail Transfer Protocol)を用いてセキュアなメールの送信ができる <br/>
-   ファイルの送信 <br/>
-   非同期サポート <br/>
-   ユニコードサポート <br/>
    
    などなど欲しい機能が一通り揃っています。 <br/>


## さくらのメールボックスとは {#さくらのメールボックスとは}

かの有名なさくらインターネットさんが用意されているプランの一つで、 <br/>

-   独自ドメインのメールが使える <br/>
-   月額 87円（安すぎでは？） <br/>
    
    と主に月額にひかれて使い始めました。 <br/>


## やりたいこと {#やりたいこと}

[さくらのメールボックスの登録](https://www.sakura.ne.jp/mail/)、[独自ドメインの追加](https://help.sakura.ad.jp/360000237321/#03)、[メールアドレスの作成](https://help.sakura.ad.jp/360000225362/#02)は済んでいるものとします。 <br/>
Rust 内から lettre を使って独自ドメインからメールを送信しましょう。 <br/>

まず、公式のサンプルを見てみます。 <br/>

```rust
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};

let email = Message::builder()
  .from("NoBody <nobody@domain.tld>".parse().unwrap())
  .reply_to("Yuin <yuin@domain.tld>".parse().unwrap())
  .to("Hei <hei@domain.tld>".parse().unwrap())
  .subject("Happy new year")
  .body(String::from("Be happy!"))
  .unwrap();

let creds = Credentials::new("smtp_username".to_string(), "smtp_password".to_string());

// Open a remote connection to gmail
let mailer = SmtpTransport::relay("smtp.gmail.com")
  .unwrap()
  .credentials(creds)
  .build();

// Send the email
match mailer.send(&email) {
  Ok(_) => println!("Email sent successfully!"),
  Err(e) => panic!("Could not send email: {:?}", e),
```

ここで必要になるものが <br/>

```rust
let creds = Credentials::new("smtp_username".to_string(), "smtp_password".to_string());

// Open a remote connection to gmail
let mailer = SmtpTransport::relay("smtp.gmail.com")
  .unwrap()
  .credentials(creds)
  .build();
```

の部分です。 <br/>

初めに `smtp_username`, `smtp_password` にそれぞれ独自ドメインを使用したメールアドレス、そのメールアドレス作成時のパスワードを設定します。 <br/>
ここでは、例としてメールアドレスが、 `dummy@exmaple_domain.com` でパスワードが、 `dummy_password` であるものとします。 <br/>

続いて、 `mailer` の接続情報ですが、ここに初期ドメインを設定します。アカウント情報から見れます。 <br/>
例として、 `example.initial.domain.com` としておきます。 <br/>

<span style="color: red"> git等にあげる際には、ドメイン情報やパスワード等を流出しないように気をつけてください。</span> <br/>

したがって、ソースコードは次のようになります。 <br/>

```rust
let creds = Credentials::new("dummy@example_domain.com".to_string(), "dummy_password".to_string());

// Open a remote connection
let mailer = SmtpTransport::relay("example.initial.domain.com")
  .unwrap()
  .credentials(creds)
  .build();
```

しかし、このままではさくらのメールボックスを使った送信はできません。 <br/>

さくらのメールボックスではメールの暗号化通信に `STARTTLS` を使用します。 <br/>
したがって、mailer 部分を次のように改変します。 <br/>

```rust
// Open a remote connection using STARTTLS
let mailer = SmtpTransport::starttls_relay("exmaple.initial.domain.com")
  .unwrap()
  .credentials(creds)
  .build();
```

これにより lettre を経由して独自ドメインからメールの送信ができるようになりました。 <br/>

<span style="color: red"> git等にあげる際には、ドメイン情報やパスワード等を流出しないように気をつけてください。</span> <br/>


## 参考リンク {#参考リンク}

-   [lettre github](https://github.com/lettre/lettre) <br/>
-   [みどりみちのブログ](https://midorimici.com/posts/dokuji-domain-mail-sakura-netlify/) <br/>
-   [さくらのメールボックス](https://www.sakura.ne.jp/mail/) <br/>
-   [さくらのレンタルサーバ（ドメインの設定）](https://help.sakura.ad.jp/360000237321/#03) <br/>
-   [さくらのレンタルサーバ（メールアドレスの作成）](https://help.sakura.ad.jp/360000225362/#02)

