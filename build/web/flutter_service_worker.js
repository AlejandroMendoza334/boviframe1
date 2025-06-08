'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "f4b40137935043aa52b646cbd7ce97c2",
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
"flutter_bootstrap.js": "a71970d2593d51775eb4fe4b5c453c20",
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
