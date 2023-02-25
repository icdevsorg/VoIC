let aviate_labs = https://github.com/aviate-labs/package-set/releases/download/v0.1.4/package-set.dhall sha256:30b7e5372284933c7394bad62ad742fec4cb09f605ce3c178d892c25a1a9722e

let additions = 
[
  { name = "base", repo = "https://github.com/dfinity/motoko-base.git", version = "moc-0.8.1", dependencies = []: List Text },
  { name = "candy_0_1_12", repo = "https://github.com/aramakme/candy_library.git", version = "v0.1.12", dependencies = ["base"] },
  { name = "map_8_0_0_rc_2", repo = "https://github.com/ZhenyaUsenko/motoko-hash-map.git", version = "v8.0.0-rc.2", dependencies = ["base"] },
  { name = "map_7_0_0", repo = "https://github.com/ZhenyaUsenko/motoko-hash-map.git", version = "v7.0.0", dependencies = ["base"] },
  { name = "candy_utils_0_2_1", repo = "https://github.com/ZhenyaUsenko/motoko-candy-utils.git", version = "v0.2.1", dependencies = ["base"] },
  { name = "crypto"
    , repo = "https://github.com/aviate-labs/crypto.mo"
    , version = "v0.2.0"
    , dependencies = [ "base", "encoding" ]
  },
  {
       name="principalmo",
       repo = "https://github.com/aviate-labs/principal.mo.git",
       version = "v0.2.5",
       dependencies = ["base"]
   },
   { name = "encoding"
  , repo = "https://github.com/aviate-labs/encoding.mo"
  , version = "v0.3.2"
  , dependencies = [ "array", "base" ]
  },
   { name = "array"
  , repo = "https://github.com/aviate-labs/array.mo"
  , version = "v0.2.0"
  , dependencies = [ "base" ]
  },
  { name = "hash"
  , repo = "https://github.com/aviate-labs/hash.mo"
  , version = "v0.1.0"
  , dependencies = [ "array", "base" ]
  },
  { name = "axon"
  , repo = "https://github.com/icdevs/axon"
  , version = "v2.1.1"
  , dependencies = ["base" ]
  },
  { name = "map"
  , repo = "https://github.com/ZhenyaUsenko/motoko-hash-map"
  , version = "v7.0.0"
  , dependencies = [ "base"]
  },
  { name = "StableBuffer"
  , repo = "https://github.com/skilesare/StableBuffer"
  , version = "v0.2.0"
  , dependencies = [ "base"]
  },
  { name = "stablebuffer_0_2_0"
  , repo = "https://github.com/skilesare/StableBuffer"
  , version = "v0.2.0"
  , dependencies = [ "base"]
  },
  { name = "icrc1"
  , repo = "https://github.com/NatLabs/icrc1"
  , version = "7af28bbfa7d41a20297ff6e349ee0374f9d1b576"
  , dependencies = [ "base"]
  },
  {
    name = "httpparser",     
    repo = "https://github.com/skilesare/http-parser.mo",
    version = "v0.1.0",
    dependencies = ["base"]
  },
  {
       name = "itertools",
       version = "main",
       repo = "https://github.com/NatLabs/Itertools.mo",
       dependencies = ["base"] : List Text
    },{
       name = "StableTrieMap",
       version = "main",
       repo = "https://github.com/NatLabs/StableTrieMap",
       dependencies = ["base"] : List Text
    },
    {
       name = "yc",
       version = "development",
       repo = "https://github.com/CigDao/Your-Coin",
       dependencies = ["base"] : List Text
    },
    {
       name = "ogy_nft",
       version = "main",
       repo = "https://github.com/origyn-sa/origyn_nft",
       dependencies = ["base"] : List Text
    }

    
]

in  aviate_labs # additions
