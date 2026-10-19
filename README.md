# PTT KEP E-imza — macOS Apple Silicon kurulumu

> **Kısa yanıt:** PTT KEP Webmail'de e-imza ile yazışma yapmak istiyor ancak Mac'inizde uygulama açılmıyor mu? Bu proje, PTT KEP'in Java Web Start (JNLP) istemcisini **MacBook, MacBook Pro, MacBook Air, Mac mini ve iMac**'de (Apple Silicon / M serisi / ARM tabanlı işlemci) çift tıklayla açılan native bir `.app`'e paketler: gömülü arm64 Java 11 sayesinde Rosetta veya ayrı Java kurulumu gerekmez. **Gayriresmî topluluk çalışmasıdır; PTT tarafından hazırlanmış veya onaylanmış değildir.**
>
> **KEP mi UETS mi?** KEP (kayıtlı e-posta) ile UETS (e-tebligat) farklı sistemlerdir; işlem kodunuz hangi arayüzden alındıysa o uygulamayı kurun — kodlar karşılıklı geçmez.

## İlk kez kuranlar için

1. **Kart ve sürücü:** e-imza kartı + kart okuyucu + **arm64 AKİS sürücüsü** gerekir: [akiskart.bilgem.tubitak.gov.tr/destek](https://akiskart.bilgem.tubitak.gov.tr/tr/destek/) → "Mac OS Arm (Apple Silicon)". Kontrol: `lipo -archs /usr/local/lib/libakisp11.dylib` → `arm64`.
2. **En kolay kurulum:** [Releases](../../releases) → `PttkepEimza-arm64-*.dmg` (derleme yok). Homebrew isteğe bağlıdır: `brew install --cask adeministratorr/tap/pttkep-eimza`.
3. **Başarılı kurulum:** Uygulama açıldığında KEP Webmail girişi ve imza/PIN penceresi görünür; imzalama akışı tamamlanır.
4. **Sık hata:** "Akıllı Kart Bulunamadı" → arm64 sürücü eksik. "Geliştirici doğrulanamadı" → DMG notarize olduğu için normal açılır; kaynaktan derlemede sağ tık → **Aç**.
5. **Önemli sınır:** Gerçek AKİS kartıyla uçtan uca imzalama doğrulandı (tek kurulumda test edildi); farklı kart/okuyucu ve sürücü sürümlerinde davranış değişebilir. Uygulama yalnızca **arm64** içindir; Intel Mac desteklenmez. İmza PIN'inizi hiçbir komuta/issue'ya yazmayın.

> **Güvenlik notu:** Bu paket resmî kurum uygulaması değildir. DMG sürümü Developer ID ile imzalı ve Apple notarizasyonundan geçmiştir; sürüm notlarında `sha256` bulunur. Kaynaktan derleme ad-hoc imzalıdır; `kur.sh` betiğini çalıştırmadan önce inceleyin.

## Kimler için?
- **Avukatlar:** KEP üzerinden işlem, ihtar ve tebligat yapanlar (mevzuat gereği avukat, arabulucu ve bilirkişilere KEP/UETS yükümlülüğü bulunur).
- **Arabulucular ve bilirkişiler:** Rapor ve belgeleri KEP ile gönderenler.
- **Mali müşavirler (SMMM/YMM):** Müvekkil ve kurum yazışmalarını KEP ile yürütenler.
- **Şirket yetkilileri:** Anonim ve limited şirketlerin e-tebligat/KEP yazışmaları (Tebligat Kanunu 7/A).
- **Hukuk büroları ve kurumsal ekipler:** MacBook (M1/M2/M3/M4) ve iMac'te e-imza kurulumu ihtiyacı olanlar.

## "Mac'te e-imza çalışmıyor" arayanlar için kısa cevaplar
- **Neden Mac'te açılmıyor?** Uygulama Java Web Start (JNLP) tabanlı; Java Web Start Java 11 ve sonrasında kaldırıldı. Bu paket uygulamayı gömülü Java 11 ile native `.app`'e çevirir.
- **MacBook / MacBook Pro / MacBook Air / iMac / Mac mini'de çalışır mı?** Evet — Apple Silicon (M1/M2/M3/M4 ve sonrası) modeller destekli. Intel Mac desteklenmez.
- **Rosetta veya Java kurmam gerekir mi?** Hayır; paket ARM native (arm64) ve Java uygulamaya gömülüdür.
- **İmza için ek olarak ne gerekir?** e-imza kartı + kart okuyucu + **arm64 AKİS sürücüsü** (aşağıdaki bölüm).

## Neden Mac'te çalışmıyordu? Nasıl çözdük?

- **Sorun:** PTT KEP Webmail E-İmza modern Mac'lerde hiç açılmıyordu; eski Java ile açılsa bile Retina ekranda metinler bulanıktı.
- **Neden:** Uygulama bir Java Web Start (JNLP) uygulamasıydı; Java Web Start, Java 11 ile birlikte Oracle tarafından tamamen kaldırıldı. Ayrıca Java 8, Retina ekranlarda otomatik keskin çizim (HiDPI) yapmaz.
- **Çözüm:** Uygulama, `jpackage` ile **gömülü arm64 Java 11** çalışma zamanı içeren native bir `.app`'e çevrildi. JNLP'nin sunucudan okuduğu `jnlp.config` adresi uygulamaya gömüldü (aksi hâlde uygulama sunucuyu bulamaz); Java 11 ile Retina'da keskin görünüm geldi.
- **Kart erişimi:** PTT KEP jar'ı kartı TÜBİTAK ESYA API + `javax.smartcardio` ile okur; bu nedenle sistemde **arm64 AKİS sürücüsü** kurulu olması yeterlidir (koda ek yama gerekmedi).
- **Doğrulama:** Gerçek AKİS kartı ve PIN ile imzalama Apple Silicon'da uçtan uca test edildi.

## Kurulum (3 yol)
1. **Hazır DMG (en hızlı):** [Releases](../../releases) → `PttkepEimza-arm64-*.dmg`.
2. **Homebrew cask (hazır DMG, derleme beklemez):**

```bash
brew install --cask adeministratorr/tap/pttkep-eimza
```

3. **Tek satır (kaynaktan derler; betiği önce inceleyin):** aşağıdaki "Kolay kurulum" bölümü.

Diğer araçlar (aynı tap): [e-Devlet E-İmza](https://github.com/adeministratorr/edevlet-eimza-mac-arm64) · [PTT UETS / e-Tebligat](https://github.com/adeministratorr/uets-eimza-mac-arm64) · [TNB Teknoloji İmza](https://github.com/adeministratorr/tnb-eimza-mac-arm64) · [UHAP İmzalama](https://github.com/adeministratorr/uhap-eimza-mac-arm64) · [UDF QuickLook](https://github.com/adeministratorr/udf-quicklook-extension) · [UYAP Doküman Editörü](https://github.com/adeministratorr/ude-mac-arm64-1)

---

## PTT KEP E-İmza — Native Apple Silicon (arm64) .app

[PTT KEP](https://pttkep.gov.tr) Webmail E-İmza Uygulaması, bir Java Web
Start (JNLP) uygulamasıdır. Java Web Start, Java 11+ ile kaldırıldığından
uygulama modern Mac'lerde kolayca açılamıyor. Bu depo, uygulamayı **gömülü
arm64 Java 11 runtime'ı** ile **çift tıklayıp açabileceğiniz native bir
`.app`'e** paketler — Rosetta gerektirmez, ayrıca Java kurmanıza gerek kalmaz.

> ⚠️ **Bu depo PTT KEP E-İmza uygulamasının kaynak kodunu içermez.** Tamamen
> bağımsız, **gayriresmî** bir Mac **paketleyicisidir**: hiçbir kamu kurumu
> tarafından geliştirilmemiş/onaylanmamıştır. Burada bulunan yalnızca paketleme
> ve build betikleridir; resmî `elektronik-imza.jar`'ı build sırasında
> ptt.hs01.kep.tr'den **siz** indirir ve native `.app`'i **siz** üretirsiniz.
> "Olduğu gibi" sunulur.

> ✅ Apple Silicon'da **gerçek kartla tam imzalama** (sertifika → PIN → imza)
> doğrulandı. (Tek bir kurulumda test edildi; yine de farklı kart/sürücü
> sürümlerinde değişiklik olabilir.)

---

## 👩‍💼 Kolay kurulum — tek satır

Programcı olmanıza gerek yok. **Terminal** uygulamasını açın (klavyede
`Command (⌘) + Boşluk`'a basıp açılan kutuya **Terminal** yazın ve **Enter**'a
basın), ardından aşağıdaki **tek satırı** kopyalayıp yapıştırın ve **Enter**'a
basın:

```bash
curl -fsSL https://raw.githubusercontent.com/adeministratorr/pttkep-eimza-mac-arm64/main/kur.sh | bash
```

> Terminal'iniz Rosetta (x86_64) modunda açılmışsa betik bunu algılayıp kendini
> otomatik olarak arm64'e geçirir — `arch -arm64` yazmanıza gerek yoktur.

Hepsi bu kadar. Manuel indirme, klasöre girme, Java kurma gibi adımlar **yok**. Bu
komut gerisini sizin için yapar:

- Gerekiyorsa **geliştirici araçlarını** (Xcode komut satırı araçları) kurar — bir
  pencere açılırsa yalnızca **"Yükle"**ye basıp bitmesini bekleyin, betik
  kendiliğinden devam eder.
- **Kaynak kodu** `~/pttkep-eimza-mac-arm64` klasörüne indirir (zaten varsa en
  güncel sürüme günceller).
- Gereken **Java** sürümlerini otomatik indirir.
- Resmî `elektronik-imza.jar`'ı ptt.hs01.kep.tr'den indirir, uygulamayı **derler +
  imzalar** ve doğrudan **/Applications** klasörüne kurar.

İlk derleme internet hızınıza göre birkaç dakika sürebilir.

Bittiğinde uygulama **Launchpad** ve **Applications** klasöründe hazırdır; çift
tıklayarak açabilirsiniz. (Kendiniz derleyip imzaladığınız için macOS "geliştirici
doğrulanamadı" uyarısı **çıkmaz**; `xattr` ile uğraşmanıza gerek yoktur.)

**Yeni sürüm çıktığında yukarıdaki tek satırı yeniden çalıştırmanız yeterli. En
güncel sürüm otomatik inecek ve paketlenecek.**

> İsterseniz sürükle-bırak yerleşimli bir `.dmg` de üretebilirsiniz:
> `brew install create-dmg` sonrası `make dmg`.

> ⚠️ **E-imza için arm64 AKİS sürücüsü ŞART** (aşağıdaki bölüm). Uygulama native
> arm64'tür; kart sürücünüz de arm64 olmalıdır.

---

## ⚠️ Apple Silicon (arm64) AKİS sürücüsü kurulumu (zorunlu)

Bu uygulama native arm64 çalışır. **Bir arm64 uygulama, yalnızca Intel (x86_64)
derlenmiş bir sürücüyü yükleyemez** (mimari uyuşmazlığı). TÜBİTAK AKİS'in macOS
için **ayrı Intel ve Apple Silicon paketleri** vardır; çoğu kullanıcıda
eski/Intel sürüm kuruludur.

**Çözüm:** Apple Silicon AKİS paketini kurun:

1. [TÜBİTAK BİLGEM AKİS — Destek/İndirme](https://akiskart.bilgem.tubitak.gov.tr/tr/destek/)
   sayfasından **"Mac OS Arm (Apple Silicon)"** başlığı altındaki güncel paketi indirin
   (ör. `Akia_macos_arm_6_8_9.pkg`). **"Mac OS Intel" paketini değil**, Arm paketini seçin.
2. İndirilen `.pkg`'a çift tıklayıp kurulumu tamamlayın (yönetici şifresi ister).
3. **PTT KEP E-İmza** uygulamasını kapatıp yeniden açın; kartı takıp deneyin.

**Doğru sürümü kurduğunuzu teyit:** Terminal'de şu komut **`x86_64 arm64`** (veya
en azından `arm64`) yazmalı — sadece `x86_64` yazıyorsa hâlâ Intel sürüm kuruludur:

```
lipo -archs /usr/local/lib/libakisp11.dylib
```

> **macOS 28 / Rosetta uyarısı:** Sistemde eski **Intel** AKİS paketi kuruluysa macOS, `/Applications/Akia.app` için "bu uygulama gelecek macOS sürümünde açılmayacak" uyarısı gösterir (Rosetta desteği macOS 28'de kaldırılıyor). TÜBİTAK'ın **Arm (Apple Silicon)** paketini kurduysanız yeni sürüm `Akia ARM.app` (arm64) olarak gelir; eski `/Applications/Akia.app`'i Finder'da Çöp'e sürükleyip kaldırın. Bu uyarı e-imza akışını etkilemez — kart erişimi yukarıdaki `libakisp11.dylib` üzerinden yürür.

---

## 🛠️ Mühendisler için — Teknik ayrıntı

Yukarıdaki adımlar derlemek için yeterlidir. Bu bölüm, tek tek build hedeflerini
ve dönüşümün **neyi nasıl** çözdüğünü açıklar. Gereksinimler kendiliğinden kurulur
(Azul Zulu 11 + 21). Apple Silicon Mac'te:

```bash
make all          # download → icns → package → sign
make run          # üretilen .app'i aç
make dmg          # sürükle-bırak yerleşimli .dmg üret (brew install create-dmg gerekir)
```

DMG arka planı `assets/dmg-background.svg`'den üretilir; düzenleyip `make assets`
ile yeniden render edebilirsiniz (`brew install librsvg`). Tek tek hedefler için `make help`.

### Nasıl çalışır

- `jpackage --type app-image` + `--runtime-image <tam arm64 Zulu 11>` ile
  uygulama ve **gömülü Java 11 runtime** tek bir native `.app`'e paketlenir.
  Tam JRE şarttır (jlink-strip değil): smartcardio/crypto provider'ları gerekir.
- **Neden Java 11:** otomatik HiDPI (JEP 263) → Retina'da keskin metin
  (arm64 Java 8 Swing bulanık render ediyor). `elektronik-imza.jar` Java 7
  bytecode'dur (major 51) ve Java 11'de sorunsuz çalışır.
- **`-Djnlp.config` (kritik):** JNLP, uygulamaya
  `jnlp.config=https://ptt.hs01.kep.tr/download/config.properties` property'sini
  geçirir; sunucu adresleri (getVersion/eSign) bu dosyadan okunur. jpackage
  `--java-options` ile bu property `.app`'e gömülür — yoksa uygulama sunucuyu
  bulamaz.
- **Kart erişimi (e-Devlet'ten fark):** PTT KEP jar'ı IAIK PKCS#11 wrapper
  DEĞİL, TÜBİTAK ESYA API (`APDUSmartCard`) + `javax.smartcardio` kullanır;
  jar'da kart erişimi için native kütüphane taşınmaz. Bu yüzden e-Devlet
  paketleyicisindeki Javassist connect-fix patch'i burada gerekmez. AKİS
  middleware'inin arm64 sürümü sistemde kurulu olmalıdır.
- **İkon:** codebase'deki `logo.png` 404 verdiğinden ikon jar içindeki
  `images/logo.png`'den (200×200) çıkarılıp `.icns`'e dönüştürülür.
- **codesign + Türkçe karakter:** `.app` adındaki `İ` gibi karakterler imzayı
  bozuyor; bu yüzden executable ASCII tutulur (`PTTKEPEImza`), görünen ad
  sonradan `CFBundleName`/`CFBundleDisplayName` ile Türkçe yapılır. Ad-hoc imza
  (`codesign -s -`) uygulanır.

### JNLP gerçekleri (kaynak)

| Alan | Değer |
|------|-------|
| codebase | `https://ptt.hs01.kep.tr/download` |
| ana jar | `elektronik-imza.jar` (~26 MB, self-contained) |
| main-class | `tr.gov.ptt.kep.digitalsignature.swing.FrmApplet` |
| j2se | 1.7+ · all-permissions |
| jnlp.config | `https://ptt.hs01.kep.tr/download/config.properties` (sunucu adresleri) |
| sürüm | `1.2.5` (pencere başlığı; config'teki `applet.version=10.0.1` applet protokol sürümüdür) |
| ikon | jar içi `images/logo.png` → `.icns` |

---

## CI build (isteğe bağlı)

`.github/workflows/release.yml` elle tetiklenir (`workflow_dispatch`):
macos-14 (arm64) runner'da `.app` üretir, mimariyi+imzayı doğrular ve
`<APP_VERSION>_<N>` etiketli bir yayın oluşturur.
