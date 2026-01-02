---
title: "Rust (lettre) とさくらのメールボックスでメール送信"
date: 2021-06-01
description: "Rust lettre & さくらメールボックス"
draft: false
---

## はじめに

Rust の lettre クレートでさくらのメールボックスを用いて独自ドメインでのメールを送信する際の記録です。  

前提としては、  

-   xdomain にて独自ドメインを取得済み
-   Netlify DNS にネームサーバを設定してる
    
    独自ドメインのメールアドレスでメールの送信がしたいが、ネームサーバは変更したくないというような状態です。  


## lettre

Rust のメーラライブラリで、  

-   SMTP(Simple Mail Transfer Protocol)を用いてセキュアなメールの送信ができる
-   ファイルの送信
-   非同期サポート
-   ユニコードサポート
    
    などなど欲しい機能が一通り揃っています。  
	[GitHub へのリンク](https://github.com/lettre/lettre)


## さくらのメールボックスとは

かの有名なさくらインターネットさんが用意されているプランの一つで、  

-   独自ドメインのメールが使える
-   月額 87円（安すぎでは？） 
    
    と主に月額にひかれて使い始めました。  


## やりたいこと

[さくらのメールボックスの登録](https://www.sakura.ne.jp/mail/)、[独自ドメインの追加](https://help.sakura.ad.jp/360000237321/#03)、[メールアドレスの作成](https://help.sakura.ad.jp/360000225362/#02)は済んでいるものとします。  
Rust 内から lettre を使って独自ドメインからメールを送信しましょう。  

まず、公式のサンプルを見てみます。  

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

ここで必要になるものが  

```rust
let creds = Credentials::new("smtp_username".to_string(), "smtp_password".to_string());

// Open a remote connection to gmail
let mailer = SmtpTransport::relay("smtp.gmail.com")
  .unwrap()
  .credentials(creds)
  .build();
```

の部分です。  

初めに `smtp_username`, `smtp_password` にそれぞれ独自ドメインを使用したメールアドレス、そのメールアドレス作成時のパスワードを設定します。  
ここでは、例としてメールアドレスが、 `dummy@exmaple_domain.com` でパスワードが、 `dummy_password` であるものとします。  

続いて、 `mailer` の接続情報ですが、ここに初期ドメインを設定します。アカウント情報から見れます。  
例として、 `example.initial.domain.com` としておきます。  

したがって、ソースコードは次のようになります。  

```rust
let creds = Credentials::new("dummy@example_domain.com".to_string(), "dummy_password".to_string());

// Open a remote connection
let mailer = SmtpTransport::relay("example.initial.domain.com")
  .unwrap()
  .credentials(creds)
  .build();
```

しかし、このままではさくらのメールボックスを使った送信はできません。  

さくらのメールボックスではメールの暗号化通信に `STARTTLS` を使用します。  
したがって、mailer 部分を次のように改変します。  

```rust
// Open a remote connection using STARTTLS
let mailer = SmtpTransport::starttls_relay("exmaple.initial.domain.com")
  .unwrap()
  .credentials(creds)
  .build();
```

これにより lettre を経由して独自ドメインからメールの送信ができるようになりました。  


## 参考リンク

-   [lettre github](https://github.com/lettre/lettre)
-   [みどりみちのブログ](https://midorimici.com/posts/dokuji-domain-mail-sakura-netlify/)
-   [さくらのメールボックス](https://www.sakura.ne.jp/mail/)
-   [さくらのレンタルサーバ（ドメインの設定）](https://help.sakura.ad.jp/360000237321/#03)
-   [さくらのレンタルサーバ（メールアドレスの作成）](https://help.sakura.ad.jp/360000225362/#02)

