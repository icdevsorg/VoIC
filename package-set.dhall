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
  { name = "hash"
  , repo = "https://github.com/aviate-labs/hash.mo"
  , version = "v0.1.0"
  , dependencies = [ "array", "base" ]
  },
]
