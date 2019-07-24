import strutils, os

when defined(recaptcha):
  import recaptcha, parsecfg, asyncdispatch, contra
  export recaptcha

from strtabs import newStringTable, modeStyleInsensitive
from packages/docutils/rstgen import rstToHtml
from packages/docutils/rst import RstParseOption


# curl -s http://data.iana.org/TLD/tlds-alpha-by-domain.txt | sed '1d; s/^ *//; s/ *$//; /^$/d' | awk '{print length" "$0}' | sort -rn | cut -d' ' -f2- | tr '\n' '|' | tr '[:upper:]' '[:lower:]' | sed 's/\(.*\)./\1/'
const inputMail = (
  r"""<input type="email" value="$1" name="$2" class="$3" id="$4" placeholder="$5" title="$5" $6 """ &
  r"""autocomplete="email" minlength="3" maxlength="254" onClick="if(this.value===''){this.value='@'}" """ &
  r"""onblur="this.value=this.value.replace(/\s\s+/g,' ').replace(/^\s+|\s+$$/g,'').toLowerCase()" dir="auto" """ &
  r"""pattern="[a-zA-Z0-9.!#$$%&’*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\.+(xn--vermgensberatung-pwb|xn--vermgensberater-ctb|xn--clchc0ea0b2g2a9gcd|xn--w4r85el8fhu5dnra|travelersinsurance|northwesternmutual|xn--xkc2dl3a5ee0h|xn--mgberp4a5d4ar|xn--mgbai9azgqp6j|xn--mgbah1a3hjkrd|xn--bck1b9a5dre4c|xn--5su34j936bgsg|xn--3oq18vl8pn36a|xn--xkc2al3hye2a|xn--mgba7c0bbn0a|xn--fzys8d69uvgm|xn--nqv7fs00ema|xn--mgbc0a9azcg|xn--mgbaakc7dvf|xn--mgba3a4f16a|xn--lgbbat1ad8j|xn--kcrx77d1x4a|xn--i1b6b1a6a2e|sandvikcoromant|kerryproperties|americanexpress|xn--rvc1e0am3e|xn--mgbx4cd0ab|xn--mgbi4ecexp|xn--mgbca7dzdo|xn--mgbbh1a71e|xn--mgbb9fbpob|xn--mgbayh7gpa|xn--mgbaam7a8h|xn--mgba3a3ejt|xn--jlq61u9w7b|xn--h2breg3eve|xn--fiq228c5hs|xn--b4w605ferd|xn--80aqecdr1a|xn--6qq986b3xl|xn--54b7fta0cc|weatherchannel|kerrylogistics|cookingchannel|cancerresearch|bananarepublic|americanfamily|afamilycompany|xn--ygbi2ammx|xn--yfro4i67o|xn--tiq49xqyj|xn--h2brj9c8c|xn--fzc2c9e2c|xn--fpcrj9c3d|xn--eckvdtc9d|wolterskluwer|travelchannel|spreadbetting|lifeinsurance|international|xn--qcka1pmc|xn--ogbpf8fl|xn--ngbe9e0a|xn--ngbc5azd|xn--mk1bu44c|xn--mgbt3dhd|xn--mgbpl2fh|xn--mgbgu82a|xn--mgbab2bd|xn--mgb9awbf|xn--gckr3f0f|xn--8y0a063a|xn--80asehdb|xn--80adxhks|xn--45br5cyl|xn--3e0b707e|versicherung|scholarships|lplfinancial|construction|xn--zfr164b|xn--xhq521b|xn--w4rs40l|xn--vuq861b|xn--t60b56a|xn--ses554g|xn--s9brj9c|xn--rovu88b|xn--rhqv96g|xn--q9jyb4c|xn--pgbs0dh|xn--pbt977c|xn--otu796d|xn--nyqy26a|xn--mix891f|xn--mgbtx2b|xn--mgbbh1a|xn--kpu716f|xn--kpry57d|xn--kprw13d|xn--jvr189m|xn--j6w193g|xn--imr513n|xn--hxt814e|xn--h2brj9c|xn--gk3at1e|xn--gecrj9c|xn--g2xx48c|xn--flw351e|xn--fjq720a|xn--fct429k|xn--estv75g|xn--efvy88h|xn--d1acj3b|xn--czr694b|xn--cck2b3b|xn--9krt00a|xn--80ao21a|xn--6frz82g|xn--55qw42g|xn--45brj9c|xn--42c2d9a|xn--3hcrj9c|xn--3ds443g|xn--3bst00m|xn--2scrj9c|xn--1qqw23a|xn--1ck2e1b|xn--11b4c3d|williamhill|rightathome|redumbrella|progressive|productions|playstation|photography|olayangroup|motorcycles|lamborghini|kerryhotels|investments|foodnetwork|enterprises|engineering|creditunion|contractors|calvinklein|bridgestone|blockbuster|blackfriday|barclaycard|accountants|xn--y9a3aq|xn--wgbl6a|xn--wgbh1c|xn--unup4y|xn--pssy2u|xn--o3cw4h|xn--mxtq1m|xn--kput3i|xn--io0a7i|xn--fiqz9s|xn--fiqs8s|xn--fiq64b|xn--czru2d|xn--czrs0t|xn--cg4bki|xn--c2br7g|xn--9et52u|xn--9dbq2a|xn--90a3ac|xn--80aswg|xn--5tzm5g|xn--55qx5d|xn--4gbrim|xn--45q11c|xn--3pxu8k|xn--30rr7y|volkswagen|vlaanderen|vistaprint|university|telefonica|technology|tatamotors|swiftcover|schaeffler|restaurant|republican|realestate|prudential|protection|properties|onyourside|nextdirect|newholland|nationwide|mitsubishi|management|industries|immobilien|healthcare|foundation|extraspace|eurovision|cuisinella|creditcard|consulting|capitalone|boehringer|bnpparibas|basketball|associates|apartments|accountant|yodobashi|xn--vhquv|xn--tckwe|xn--p1acf|xn--nqv7f|xn--ngbrx|xn--l1acc|xn--j1amh|xn--j1aef|xn--fhbei|xn--e1a4c|xn--d1alf|xn--c1avg|xn--90ais|vacations|travelers|stockholm|statefarm|statebank|solutions|shangrila|scjohnson|richardli|pramerica|passagens|panasonic|microsoft|melbourne|marshalls|marketing|lifestyle|landrover|lancaster|ladbrokes|kuokgroup|insurance|institute|honeywell|homesense|homegoods|homedepot|hisamitsu|goldpoint|furniture|fujixerox|frontdoor|fresenius|firestone|financial|fairwinds|equipment|education|directory|community|christmas|bloomberg|barcelona|aquarelle|analytics|amsterdam|allfinanz|alfaromeo|accenture|yokohama|xn--qxam|xn--p1ai|xn--node|xn--90ae|woodside|verisign|ventures|vanguard|uconnect|training|symantec|supplies|stcgroup|software|softbank|showtime|shopping|services|security|samsclub|saarland|reliance|redstone|property|plumbing|pictures|pharmacy|partners|observer|movistar|mortgage|merckmsd|memorial|mckinsey|maserati|marriott|lundbeck|lighting|jpmorgan|istanbul|ipiranga|infiniti|hospital|holdings|helsinki|hdfcbank|guardian|graphics|grainger|goodyear|frontier|football|firmdale|fidelity|feedback|exchange|everbank|etisalat|esurance|ericsson|engineer|download|discover|discount|diamonds|democrat|deloitte|delivery|computer|commbank|clothing|clinique|cleaning|cityeats|cipriani|chrysler|catholic|catering|capetown|business|builders|budapest|brussels|broadway|bradesco|boutique|baseball|bargains|barefoot|barclays|attorney|allstate|airforce|abudhabi|zuerich|youtube|yamaxun|xfinity|winners|windows|whoswho|wedding|website|weather|watches|wanggou|walmart|trading|toshiba|tiffany|tickets|theatre|theater|temasek|systems|surgery|support|storage|starhub|staples|singles|shriram|shiksha|science|schwarz|schmidt|sandvik|samsung|rexroth|reviews|rentals|recipes|realtor|politie|pioneer|philips|origins|organic|oldnavy|okinawa|neustar|network|netflix|netbank|monster|metlife|markets|lincoln|limited|liaison|leclerc|latrobe|lasalle|lanxess|lancome|lacaixa|komatsu|kitchen|juniper|jewelry|ismaili|iselect|hyundai|hotmail|hoteles|hosting|holiday|hitachi|hangout|hamburg|guitars|grocery|godaddy|genting|gallery|fujitsu|frogans|forsale|flowers|florist|flights|fitness|fishing|finance|ferrero|ferrari|fashion|farmers|express|exposed|domains|digital|dentist|cruises|cricket|courses|coupons|country|corsica|cooking|contact|compare|company|comcast|cologne|college|clubmed|citadel|chintai|charity|channel|cartier|careers|caravan|capital|bugatti|brother|booking|bestbuy|bentley|bauhaus|banamex|avianca|auspost|audible|auction|athleta|android|alibaba|agakhan|academy|abogado|zappos|yandex|yachts|xihuan|webcam|warman|walter|vuelos|voyage|voting|vision|virgin|villas|viking|viajes|unicom|travel|toyota|tkmaxx|tjmaxx|tienda|tennis|tattoo|target|taobao|taipei|sydney|swatch|suzuki|supply|studio|stream|social|soccer|shouji|select|secure|search|schule|school|sanofi|sakura|safety|ryukyu|rogers|rocher|review|report|repair|reisen|realty|racing|quebec|pictet|piaget|physio|photos|pfizer|otsuka|orange|oracle|online|olayan|office|nowruz|norton|nissay|nissan|natura|nagoya|mutual|museum|moscow|mormon|monash|mobily|mobile|mattel|market|makeup|maison|madrid|luxury|london|locker|living|lefrak|lawyer|latino|lancia|kosher|kindle|kinder|kaufen|juegos|joburg|jaguar|intuit|insure|imamat|hughes|hotels|hockey|hiphop|hermes|health|gratis|google|global|giving|george|garden|gallup|futbol|flickr|family|expert|events|estate|energy|emerck|durban|dupont|dunlop|doctor|direct|design|dental|degree|dealer|datsun|dating|cruise|credit|coupon|condos|comsec|coffee|clinic|claims|circle|church|chrome|chanel|center|casino|caseih|career|camera|broker|boston|bostik|bharti|berlin|beauty|bayern|author|aramco|anquan|alstom|alsace|alipay|airtel|airbus|agency|africa|abbvie|abbott|abarth|yahoo|xerox|world|works|weibo|weber|watch|wales|volvo|vodka|video|vegas|ubank|tushu|tunes|trust|trade|tours|total|toray|tools|tokyo|today|tmall|tirol|tires|tatar|swiss|sucks|style|study|store|stada|sport|space|solar|smile|smart|sling|skype|shoes|shell|sharp|seven|sener|salon|rugby|rodeo|rocks|ricoh|reise|rehab|radio|quest|promo|prime|press|praxi|poker|place|pizza|photo|phone|party|parts|paris|osaka|omega|nowtv|nokia|ninja|nikon|nexus|nadex|movie|mopar|money|miami|media|mango|macys|lupin|lotto|lotte|locus|loans|lixil|lipsy|linde|lilly|lexus|legal|lease|lamer|kyoto|koeln|jetzt|iveco|irish|intel|ikano|hyatt|house|horse|honda|homes|guide|gucci|group|gripe|green|gmail|globo|glass|glade|gives|gifts|games|gallo|forum|forex|final|fedex|faith|epson|email|edeka|earth|dubai|drive|dodge|delta|deals|dance|dabur|cymru|crown|codes|coach|cloud|click|citic|cisco|cheap|chase|cards|canon|build|bosch|boats|black|bingo|bible|beats|baidu|azure|autos|audio|archi|apple|amica|amfam|aetna|adult|actor|zone|zero|zara|yoga|xbox|work|wine|wiki|wien|weir|wang|voto|vote|vivo|viva|visa|vana|tube|toys|town|tips|tiaa|teva|tech|team|taxi|talk|surf|star|spot|sony|song|sohu|sncf|skin|site|sina|silk|show|shop|shia|shaw|sexy|seek|seat|scot|scor|saxo|save|sarl|sale|safe|ruhr|rsvp|room|rmit|rich|rest|rent|reit|read|raid|qpon|prof|prod|post|porn|pohl|plus|play|pink|ping|pics|pccw|pars|page|open|ollo|nike|nico|next|news|navy|name|moto|moda|mobi|mint|mini|menu|meme|meet|maif|luxe|ltda|love|loft|loan|live|link|limo|like|life|lidl|lgbt|lego|land|kred|kpmg|kiwi|kddi|jprs|jobs|jeep|java|itau|info|immo|imdb|ieee|icbc|hsbc|host|hgtv|here|help|hdfc|haus|hair|guru|guge|goog|golf|gold|gmbh|gift|ggee|gent|gbiz|game|fund|free|ford|food|flir|fish|fire|film|fido|fiat|fast|farm|fans|fail|fage|erni|dvag|duns|duck|doha|docs|dish|diet|desi|dell|deal|dclk|date|data|cyou|coop|cool|club|city|citi|chat|cern|cbre|cash|case|casa|cars|care|camp|call|cafe|buzz|book|bond|bofa|blue|blog|bing|bike|best|beer|bbva|bank|band|baby|auto|audi|asia|asda|arte|arpa|army|arab|amex|ally|akdn|aigo|aero|adac|able|aarp|zip|yun|you|xyz|xxx|xin|wtf|wtc|wow|wme|win|wed|vip|vin|vig|vet|ups|uol|uno|ubs|tvs|tui|trv|top|tjx|thd|tel|tdk|tci|tax|tab|stc|srt|srl|soy|sky|ski|sfr|sex|sew|ses|scb|sca|sbs|sbi|sas|sap|rwe|run|rip|rio|ril|ren|red|qvc|pwc|pub|pru|pro|pnc|pin|pid|phd|pet|pay|ovh|ott|org|ooo|onl|ong|one|off|obi|nyc|ntt|nrw|nra|now|nhk|ngo|nfl|new|net|nec|nba|nab|mtr|mtn|msd|mov|mom|moi|moe|mma|mls|mlb|mit|mil|men|med|mba|map|man|ltd|lpl|lol|llc|lds|law|lat|krd|kpn|kim|kia|kfh|joy|jot|jnj|jmp|jll|jio|jcp|jcb|itv|ist|int|ink|ing|inc|ifm|icu|ice|ibm|how|hot|hkt|hiv|hbo|gov|got|gop|goo|gmx|gmo|gle|gea|gdn|gap|gal|fyi|fun|ftr|frl|fox|foo|fly|fit|fan|eus|esq|edu|eco|eat|dvr|dtv|dot|dog|dnp|diy|dhl|dev|dds|day|dad|csc|crs|com|cfd|cfa|ceo|ceb|cbs|cbn|cba|cat|car|cam|cal|cab|bzh|buy|box|bot|boo|bom|bnl|bmw|bms|biz|bio|bid|bet|bcn|bcg|bbt|bbc|bar|axa|aws|art|app|aol|anz|aig|afl|aeg|ads|aco|abc|abb|aaa|zw|zm|za|yt|ye|ws|wf|vu|vn|vi|vg|ve|vc|va|uz|uy|us|uk|ug|ua|tz|tw|tv|tt|tr|to|tn|tm|tl|tk|tj|th|tg|tf|td|tc|sz|sy|sx|sv|su|st|ss|sr|so|sn|sm|sl|sk|sj|si|sh|sg|se|sd|sc|sb|sa|rw|ru|rs|ro|re|qa|py|pw|pt|ps|pr|pn|pm|pl|pk|ph|pg|pf|pe|pa|om|nz|nu|nr|np|no|nl|ni|ng|nf|ne|nc|na|mz|my|mx|mw|mv|mu|mt|ms|mr|mq|mp|mo|mn|mm|ml|mk|mh|mg|me|md|mc|ma|ly|lv|lu|lt|ls|lr|lk|li|lc|lb|la|kz|ky|kw|kr|kp|kn|km|ki|kh|kg|ke|jp|jo|jm|je|it|is|ir|iq|io|in|im|il|ie|id|hu|ht|hr|hn|hm|hk|gy|gw|gu|gt|gs|gr|gq|gp|gn|gm|gl|gi|gh|gg|gf|ge|gd|gb|ga|fr|fo|fm|fk|fj|fi|eu|et|es|er|eg|ee|ec|dz|do|dm|dk|dj|de|cz|cy|cx|cw|cv|cu|cr|co|cn|cm|cl|ck|ci|ch|cg|cf|cd|cc|ca|bz|by|bw|bv|bt|bs|br|bo|bn|bm|bj|bi|bh|bg|bf|be|bd|bb|ba|az|ax|aw|au|at|as|ar|aq|ao|am|al|ai|ag|af|ae|ad|ac)">"""
  )

const inputNumber = (
  r"""<input type="tel" value="$1" name="$2" class="$3" id="$4" placeholder="$5" title="$5" """ &
  r"""$6 min="$7" max="$8" maxlength="$9" step="1" pattern="\d*" autocomplete="off" dir="auto">"""
  )

const inputFile = (
  r"""<input type="file" name="$1" class="$2" id="$3" title="$5" accept="$5" $4 """ &
  r"""onChange="if(!this.value.toLowerCase().match(/(.*?)\.($6)$$/)){alert('Invalid File Format. ($5)');this.value='';return false}">"""
  )

const
  imageLazy = """
  <img class="$5" id="$2" alt="$6" data-src="$1" src="" lazyload="on" onclick="this.src=this.dataset.src" onmouseover="this.src=this.dataset.src" width="$3" heigth="$4"/>
  <script>
    const i = document.querySelector("img#$2");
    window.addEventListener('scroll',()=>{if(i.offsetTop<window.innerHeight+window.pageYOffset+99){i.src=i.dataset.src}});
    window.addEventListener('resize',()=>{if(i.offsetTop<window.innerHeight+window.pageYOffset+99){i.src=i.dataset.src}});
  </script>"""


template inputEmailHtml*(value="", name="", class="input", id="", placeholder="Email", required=true): string =
  ## HTML Input Email, validates **before** Submit, validates IANA TLDs. https://coliff.github.io/html5-email-regex
  inputMail.format(value, name, class, id, placeholder, if required: "required" else: "")


template inputNumberHtml*(value="", name="", class="input", id="", placeholder="0", required=true, min:byte=0.byte, max:int=byte.high.int, maxlenght=3): string =
  ## HTML Input Number, no Negative, maxlenght enforced, dir auto, etc.
  inputNumber.format(value, name, class, id, placeholder, if required: "required" else: "", min, max, maxlenght)


template inputFileHtml*(name="", class="input", id="", required=true, fileExtensions=[".jpg", ".jpeg", ".gif", ".png", ".webp"]): string =
  ## HTML Input File, by default for Images but you can customize, validates **before** Upload.
  inputFile.format(name, class, id, if required: "required" else: "", fileExtensions.join(","), fileExtensions.join("|").replace(".", ""))


template imgLazyLoadHtml*(src, id: string, width="", heigth="", class="",  alt=""): string =
  ## HTML Image LazyLoad. https://codepen.io/FilipVitas/pen/pQBYQd (Must have ID!)
  imageLazy.format(src, id, width, heigth, class,  alt)


template notifyHtml*(message: string, title="NimWC 👑", iconUrl="/favicon.ico", timeout: byte = 3): string =
  "Notification.requestPermission(()=>{const n=new Notification('" & title & "',{body:'" & message.strip & "',icon:'" & iconUrl & "'});setTimeout(()=>{n.close()}," & $timeout & "000)});"


template minifyHtml*(htmlstr: string): string =
  when defined(release): replace(htmlstr, re">\s+<", "> <").strip else: htmlstr


template rst2html*(stringy: string, options={roSupportMarkdown}): string =
  ## RST/Markdown to HTML using std lib.
  try:
    rstToHtml(stringy.strip, options, newStringTable(modeStyleInsensitive))
  except:
    stringy


template checkboxToInt*(checkboxOnOff: string): string =
  ## When posting checkbox data from HTML form
  ## an "on" is sent when true. Convert to 1 or 0.
  if checkboxOnOff == "on": "1" else: "0"


template checkboxToChecked*(checkboxOnOff: string): string =
  ## When parsing DB data on checkboxes convert
  ## 1 or 0 to HTML checked to set checkbox
  if checkboxOnOff == "1": "checked" else: ""


template statusIntToText*(status: string): string =
  ## When parsing DB status convert 0, 1 and 3 to human names
  case status
  of "0": "Development"
  of "1": "Private"
  of "2": "Public"
  else:   "Error"


template statusIntToCheckbox*(status, value: string): string =
  ## When parsing DB status convert to HTML selected on selects
  if status == "0" and value == "0":
    "selected"
  elif status == "1" and value == "1":
    "selected"
  elif status == "2" and value == "2":
    "selected"
  else:
    ""


when defined(recaptcha):
  var
    useCaptcha*: bool
    captcha*: ReCaptcha

  let
    dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
    recaptchaSecretKey = dict.getSectionValue("reCAPTCHA", "Secretkey")
    recaptchaSiteKey* = dict.getSectionValue("reCAPTCHA", "Sitekey")

  proc setupReCapthca*(recaptchaSiteKey = recaptchaSiteKey, recaptchaSecretKey = recaptchaSecretKey) =
    ## Activate Google reCAPTCHA
    preconditions recaptchaSiteKey.len > 0, recaptchaSecretKey.len > 0
    if len(recaptchaSecretKey) > 0 and len(recaptchaSiteKey) > 0:
      useCaptcha = true
      captcha = initReCaptcha(recaptchaSecretKey, recaptchaSiteKey)
      echo("Initialized ReCAPTCHA.")
    else:
      useCaptcha = false
      echo("Failed to initialize ReCAPTCHA.")


  proc checkReCaptcha*(antibot, userIP: string): Future[bool] {.async.} =
    ## Check if Google reCAPTCHA is Valid
    preconditions antibot.len > 0, userIP.len > 0
    if useCaptcha:
      var captchaValid = false
      try:
        captchaValid = await captcha.verify(antibot, userIP)
      except:
        echo("Error checking captcha: " & getCurrentExceptionMsg())
        captchaValid = false
      if not captchaValid:
        echo("g-recaptcha-response", "Answer to captcha incorrect!")
        return false
      else:
        return true
    else:
      return true


runnableExamples:
  import strutils
  echo inputEmailHtml(value="user@company.com", name="myMail", class="is-rounded", id="myMail", placeholder="Email", required=true)
  echo inputNumberHtml(value="42", name="myNumber", class="is-rounded", id="myNumber", placeholder="Integer", required=true)
  echo inputFileHtml(name="myImage", class="is-rounded", id="myImage", required=true)
  echo imgLazyLoadHtml(src="myImage.jpg", class="is-rounded", id="lazyAsHell")
  echo "<button onClick=''" & notifyHtml("This is a Notification") & "'>Notification</button>"
  echo rst2html("**Hello** *World*")
  echo minifyHtml("     <p>some</p>                                          <b>HTML</b>     ") ## Minifies when -d:release
