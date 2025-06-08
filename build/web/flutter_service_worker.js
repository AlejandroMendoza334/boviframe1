'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "bae4de394cae97687163360e9f60d254",
".git/config": "1792e7430af2372258883e01379b36b4",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "d1b20010ef3f956eeba52408068e7d3e",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "83ba324e57289716b2ea6895cd176ff2",
".git/logs/refs/heads/main": "a3e9536666501037def5e8c368c40e31",
".git/logs/refs/remotes/origin/main": "9f222eef05b553da80b1f6dc71561156",
".git/objects/03/b848921c3d524aaf3e7c9e2c2311cfa496abf5": "0f1f21d8d43eb8a946a43b5900b8e55f",
".git/objects/12/ad22da8b3534f45a71f52a8718953c24f60e24": "cdd045858f751609bc8d8a8ed416101f",
".git/objects/16/22f4397b36ec590f5000690dfa4b4167d25057": "b2c9b39267b1bbdde618748c00d6c4b7",
".git/objects/1a/5227e92871dbb96c635553d1b04af05760442a": "3face6147ec7a68d12111690bed28676",
".git/objects/1a/73c3a6e6d6fce3df140a048c659b4e07a00a6f": "36fa8f2e98abc09f5d1d0a41a2731c99",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/1b/4afc5067f0d18d713ddafa6ce87d7196f2dbc0": "5ac6d79a210f6a97f5ff78b77ac11cb4",
".git/objects/21/1c6f55c8aa0f2bd72d53e7daa8228117a1e24e": "06ecddb96c32cf2b84c88a78af1a8bbb",
".git/objects/2a/f52376b3ea78b6bbf64b9d6e32764cd7159a7e": "165d4a88884174b7c16734eeff747ba0",
".git/objects/2e/939ea35e661b568106a0699c9c6380ef77723f": "2c83665e4bbce4280ecc142bda98dfc5",
".git/objects/3e/26f4a29578482fa330bbbfb290ca70e2bd8583": "241f03d7924812fae40d5c1c89bf9bfe",
".git/objects/3e/56ce038f0ba7ef9a2a2fe8fc9054c9ba1d1859": "7e4e4795a1fdd9d4116e761cee146e5d",
".git/objects/3f/d2c1a48381d3a4462f5e8810292ad0a960de4b": "e5e012cc76164913d8bb3277fb93fc4e",
".git/objects/49/5714df9fa7b74d7f3a4224c5adb82ff5faea6d": "69ae560225d8a965c38590f9d40ef859",
".git/objects/4c/2b995c0e33b38364be23cc74c2daaeefc24fec": "3b95a2cce80b58e6abe4c53db61670df",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/4c/7a2dd38141969770c1ded94801912e42cd8a5c": "6bfe2a24c42faac64a0e43f3399c5d78",
".git/objects/4f/f44d48d4dd61662749e70ffc1ebc49939df06d": "cabc5f746ba7852025c1b89100cae51e",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/58/1f148e3177e49ad67a997f11ae6e2f10868322": "0b97af10b0d9a5fc03e27758d6786baf",
".git/objects/5c/a34e2666ba02aa20c71d1fd611fdc4b9f74403": "34cfd3785546de8b873767e780db4aae",
".git/objects/5c/a411b04486327ea3d34f5830784885042df966": "143c1cac3f3039b3debb75ea5bd27bb8",
".git/objects/5c/f8e0c306bab507b24665d73e6ab8576327b304": "b9e1422cf322def20534bdee09fb842c",
".git/objects/68/8c536227b113b2f02c244efb60c6900cc0d58e": "b4b9a82b0a3712b04c33fb1367bd209f",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6d/7e2f7983913ef06ebd816f8336bf6a637e5fcc": "7f5af687bee141d9a2c71016b1d228ec",
".git/objects/6f/005ddd54f7c9cd5fd83a786a196b23ddc86888": "c312d169e8d091656c6eee78fbc775ea",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/80/8d68e50b70bbafb559c53c9b95c3b7082fc9e9": "d38f25b56948e1eb4192859a661bbd8c",
".git/objects/88/6d48509ce0047a14f2fb285b77cb1163a52551": "574e127ceb679ff6d1d4a8dc108700b6",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8b/92ceb0e1b06f35f11aab1526edd4612a21f9d9": "51e379885c0353f361acdaecf7f48836",
".git/objects/8c/c5de058c0b9a4f78ff5e5dffa53e1334e1ba00": "45dfc4a92c491d0fc35d52e5b369bbd3",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/8e/5efdde577702fa08d83a42e343ee725d414e31": "7dbcd2e0d24f9b74cc7623a3c3f7e101",
".git/objects/8e/bf7f5481d1687c843bb29a337d4b9602952de4": "08720d5f1370df5a32ee5c0bc281ae9f",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/9f/89c9de7aaa3365980727eced97964f274053d0": "8247bc378ba6e1ef003a2389236ea8d1",
".git/objects/a8/9330d7b57be24566b0c45175760a8d9ace1354": "3fcc227a98009bb7c5e85067d150d106",
".git/objects/af/db7f609d024e5ffa13456bf57a0ad609b86c87": "870b7b82c055386464602bd3444fb6ef",
".git/objects/b5/52648486adeff2f409e2d7028b1802502477fe": "04aded3ae4d23c3190f9725793efe1a0",
".git/objects/b6/753e0fc425e594dcb40fd33c984916a93647e3": "9003baa536948a3f5685afe920571879",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/bf/aef0fa42aab58ba1e35b18314949d16f2a1292": "1c265686ad1bccfcfb74c66c181a938e",
".git/objects/c3/6bf3064383b769138ebb4eab2871027c73eda4": "a6e88a19cdbc7edb33c7745e04616e0b",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/cc/de430e7be456b649a5135a69fc8098b1afe59c": "e55f02779cbacd9df2c25cd73aa87671",
".git/objects/cd/c5e492770fb70ae071f9ecac80146b402d15d5": "3c5829f32eaa04ff87c24eb01f99a29a",
".git/objects/d2/debdb382fcac39aa8f54ba0a7fa98cb2e0b60c": "93a1452f5bc50173b79e23eb34c680cc",
".git/objects/d2/eb573169695b8a9a7389bc82add68b05db413e": "7387d9148bd5f6ebc931ddaa2671b254",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/9756cbff82e13a2dd43e5e487ba69c09cfecea": "ef3b4464641027ef051d9e61d280cbfe",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/df/7379cd435b803c60e024b09329215a1223d457": "f453df7a5b6e2288f5a07c68d739cdfc",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e1/b401e268cb7001e35d2932c3ed1dae9de2672c": "a7767dea87c1888ceb974043e42527d6",
".git/objects/e5/ccde5e3fa3426dd4aa2237001682814370e838": "6823567126bdf8a5bf3f2c446a11fca8",
".git/objects/e7/d106c4421e680481973b9d78dfbe4f0f09ed97": "f80fd6cdcf1f6c406f9dcf4ca6c55fc7",
".git/objects/e8/29d3be7214a1cb43b3a0094bf74866712a7873": "a49ea0c882006709c30aeed92b9b61ec",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/8586f221648022f74483db956a4d57cbbc29b8": "0c6b8ef4950e3dc638f0e496449bf7fb",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/949458f3a766fd5b59d728dafd9c92bf361684": "d0940c2df72efdb6c5d3eff9eb7b6325",
".git/objects/f0/cb720defb96dcc7a19b0a95df9d72d47a6c74b": "414b0f2f9e63ca94f3ba2759282d8d63",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/55c80afa25a81e0f41faa1da6c57965e35726e": "86b4f8b6698d370fe1b6e490ae86ec4f",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f8/368226768c2b18f15fc7894c104f1b197273a7": "e6f334d1b88269ae63ed34be8da143a9",
".git/objects/fa/6c3b07ec2e222b275ed901769b30cc9dcacf1d": "9805dc0a003e6d5da36a15f20f147456",
".git/refs/heads/main": "ddafb57da3a0561e7882566ccc975e9a",
".git/refs/remotes/origin/main": "ddafb57da3a0561e7882566ccc975e9a",
"assets/AssetManifest.bin": "f4b40137935043aa52b646cbd7ce97c2",
"assets/AssetManifest.bin.json": "d8cb8f8f01d2126446fe8d2e575bdeb1",
"assets/AssetManifest.json": "a3f2b6701bb550a0b01f222bc2de9e73",
"assets/assets/fonts/Montserrat-Italic-VariableFont_wght.ttf": "5a669c0a71801494df35130ab2f55295",
"assets/assets/fonts/Montserrat-VariableFont_wght.ttf": "b87689f37dfb5c51719210e4d96a34a2",
"assets/assets/icons/fondo4-volteado.jpg": "9f8542652e4f79705d8478be04387707",
"assets/assets/icons/fondo4.jpg": "cae9bd56d61b200128b6b2c4b9238b4a",
"assets/assets/icons/fondo6.jpg": "c016802e94024a6d4d4fea548d2465f4",
"assets/assets/icons/IMAGOTIPO_BOVIFRAME_FONDODARK.jpg": "40ed663b2d5823ed2719e56ec9341ea4",
"assets/assets/icons/IMAGOTIPO_BOVIFRAME_SINFONDO.png": "ee6a0dd65ce7ebe20d09a6279b47cae1",
"assets/assets/icons/logo1.png": "5ca64e45eb48b073d14c1f45cdfa1803",
"assets/assets/icons/logoapp2.png": "c6170558cdcac1d9957246517d6d332d",
"assets/assets/icons/logoapp3.png": "0b663c93dd1870c4bfc3471afdfd270e",
"assets/assets/icons/logoapp4.png": "2857ea6118b9c196e7aa1d0e42c8e147",
"assets/assets/icons/logoapp5.png": "35ccd0a992c16df8f0d607883fad2b4c",
"assets/assets/img/boton_basesteoricas.jpg": "0ff1bb3d8e56094f7737633b5dca7456",
"assets/assets/img/boton_consulta.png": "5957b75ce77b80463311a9b83bfd2660",
"assets/assets/img/boton_epmuras.jpg": "8977a051911ba90c29ba4b4aff89e5a6",
"assets/assets/img/boton_estadisticas.jpg": "404e67db9496fe63ea1776211551019a",
"assets/assets/img/boton_indice.jpg": "c1ed0e77e3cd8d36204578369fc8f3a5",
"assets/assets/img/boton_noticias.jpg": "06f4599e2eec4484536fee6aa2207f28",
"assets/assets/img/boton_publicar.png": "51a8cd6abeef02b47f3d9a303ab414cc",
"assets/assets/img/facebook.png": "bf1b2e9f17e4869160342be8d2d6ca3c",
"assets/assets/img/google.png": "937c87b4439809d5b17b82728df09639",
"assets/assets/img/icono_boviframe.png": "dd1136137a076c22f36116b2ffeef11f",
"assets/assets/img/OIP.jpg": "9bcd2c95192b524dd4aa0606a47ff92c",
"assets/assets/img/vaca.jpg": "60f9ecee0dc81cc3ad86f8830f22aa32",
"assets/assets/img/vaca2.jpg": "07f07ef74a063fc44e858ec63b631de0",
"assets/assets/img/vaca3.jpg": "729cca25089ae9ca461bc2a4fb9c332c",
"assets/assets/img/vaca4.jpg": "7cf6e1c2acc3e6f1eff3a5e58e52fb5c",
"assets/FontManifest.json": "102ee5a3d74ca14582f6c7a215b60e08",
"assets/fonts/MaterialIcons-Regular.otf": "c18acc2c5e981c160a3edb0285cf42af",
"assets/NOTICES": "fa8feac5cfb8bc234701075d44d25fc5",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/quill_native_bridge_linux/assets/xclip": "d37b0dbbc8341839cde83d351f96279e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "599d0844c96048b2346fbfcd5976b246",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "cfde0b0d8d7cf75e63223f9c8bdf6b88",
"/": "cfde0b0d8d7cf75e63223f9c8bdf6b88",
"main.dart.js": "b6a15c622846d9bca071995e4d487589",
"manifest.json": "b50ce9089cf5f8d7a13225506e225925",
"version.json": "384ddfdd18400f5c8b65bafa9ec6d583"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
