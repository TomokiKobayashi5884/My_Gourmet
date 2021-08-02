# My Gourmet
---
## アプリケーション概要
ユーザー同士がグルメ写真を投稿し合うことで、お互いのグルメ情報を共有できるSNSアプリです。  
投稿の♡食べたい！ボタン（いいね！のようなもの）を押すだけで、自分だけの食べたい物リストを作成することができます。  
(レスポンシブ対応となっているため、PC、iPad、スマホからも使用することができます。）


## 作成した目的

簡潔に2点あります。  
1.グルメ好きな友人が手間をかけて食べたい物リストを作成していたため、より簡単に作成できるものを作りたいと思った。  
2.コロナ禍で経営に苦しむ飲食店の力になりたいと思った。  
My Gourmetを使用するユーザーが増えることでグルメ好きな人だけでなく、飲食店の集客にも繋がると考え、作成に至りました。  


## 機能一覧

- ユーザー登録機能、ログイン機能 [devise]　　
- ユーザー情報編集機能　　
- 退会機能　　
- 投稿機能  
  - 画像投稿機能 [CarrierWave]  
  - 画像加工機能 [minimagick]  
  - 画像プレビュー機能  
  - 店舗情報検索機能 [ホットペッパーAPI、Ajax]  
  - 店舗情報自動入力機能 [Ajax]  
- 投稿一覧機能  
  - 投稿検索機能 （キーワード、都道府県、エリア、ジャンルの複数条件対応）  
  - 食べたい数ランキング機能  
  - ページネーション機能  
  - ホットペッパーグルメ公式サイトでの検索機能  
- 投稿詳細機能  
  - コメント機能  
    - コメント削除機能 （※ 自分がしたコメントのみ）  
- 過去の投稿一覧機能（自分の投稿）  
- 投稿編集機能  
- 投稿削除機能  
- 食べたい機能 (Ajax)  
  - 食べたい数表示機能  
- 食べたい物リスト一覧機能 (自分の食べたい一覧）  
  - リスト内検索 （キーワード、都道府県、エリア、ジャンルの複数条件対応）  
- お問い合わせ機能
  - お問い合わせ内容確認機能
- レスポンシブ対応 (ハンバーガーメニュー等)
 

## 使用方法
My Gourmetでは大きく分けて3つのことができます。  
- ### 他のユーザーにグルメをオススメする  
  1.　画面上部にある＋新規投稿ボタンから新規投稿フォームへ移動  
  2.　フォーム内のオススメ？ or 食べたい?欄にて、オススメ！を選択し、グルメ記事を投稿してください。  
     (※ 投稿時、店舗情報も一緒に登録することで、投稿閲覧時に店舗情報も表示されます。）  
     (※ ホットペッパーグルメに掲載されているお店であれば、フォーム内から検索することができます。)  
- ### 食べたい物を探す  
  1.　投稿一覧画面にある投稿検索フォームにてお好みの条件を入力し、検索してください。  
     (※ キーワード、都道府県、エリア、ジャンルごとに検索できます。)  
  2.　気になる投稿があればクリックすることで、店舗情報などの情報を見ることができます。  
  3.　投稿に関する詳細な情報を知りたい場合はコメントで聞くこともできます。 
- ### 食べたい物リストを作成する  
  1.　投稿一覧、または投稿詳細画面にある♡を押すと、その投稿が食べたい物リストに追加されます。
     (※ 投稿されているグルメ以外に食べたい物がある場合は、そのグルメに関する投稿をしてください。  新規投稿時にオススメ？ or 食べたい?欄にて、食べたい！を選択することで自動的にリストに追加されます。)  
     (※ ♡をもう一度押すと、リストから削除されます。）  
  2.　画面上部、またはマイページ内の♡食べたい物リストボタンから、リストに登録したグルメ記事を見ることができます。   
    

  

