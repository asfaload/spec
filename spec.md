# Publishing Repo

## Initial signers

### Github
Added in root of git repo as `asfaload.signers.json` with the format
```
{
  "threshold": {
   "signatures_required": 1,
  },
  "signers" : [
    { "format": "minisign", "pubkey": "RWTsbRMhBdOyL8hSYo/Z4nRD6O5OvrydjXWyvd8W7QOTftBOKSSn3PH3"  },
    { "format": "minisign", "pubkey": "RWTUManqs3axpHvnTGZVvmaIOOz0jaV+SAKax8uxsWHFkcnACqzL1xyv"  },
    { "format": "minisign", "pubkey": "RWSNbF6ZeLYJLBOKm8a2QbbSb3U+K4ag1YJENgvRXfKEC6RqICqYF+NE"  }
  ]
}
```
When asfaload copies this file to the mirror, it is not signed yet and has the suffix `.pending` added. Signatures will be collected on the mirror.

The signatures of this file are placed on the mirror under `${project_root}/asfaload/signatures.pending/${base64_of_pub_key}`.
`${project_root}` is the path `/github.com/${user}/${repo}` on the mirror.
Each signer provides its signature, and it is immediately committed to the mirror.
When all required signatures are collected, the file and directory are renamed to remove the `.pending` suffix, effectively becoming the
active signature configuration.

## Signers modifications

The file `asfaload.signers.json` is updated in the root of the project's repo and asfaload is notified of the change.
The new file is copied with the suffix `.pending` added and a directory `signatures.pending` is created.
To transition to the new setup, 3 conditions have to be met:
* The current signatories need to sign the new signers file according to the current signers file.
* The new signers file needs to be respected too.
* Any new signer is required to sign.

Illustration:
old: { threshold 2, signers [ A, B, C ]}
new: { threshold 3, signers A, B, C, D}

This leads to these condition having to be met before transitioning to the new signature config:
* We need 2 signatures from A B C
* We need 3 signatures from A B C D
* We need signature D as it is a new signer.

To be noted is that the initial signers file process is a special case of these conditions, where there is no
current config, and where all signers are new, which lets us condense everything in one requirement (all signers need to sign).

An acceptable set of signatures of A B D, as it fulfills all 3 conditions.

While collecting signatures, the new signatures are added under `signatures.pending` and committed to the mirror.
As soon as the 3 conditions are met, the file and directory are renamed, dropping the `.pending` suffix.

# Mirror

## New release

The checksums files are mirrored and the `asfaload.index.json` file is created. The current `asfaload.signers.json` file is also copied
under the release directory on the mirror.
Signatures are requested according to the signers file on the mirror.
For our example, let's assume that the key `RWTsbRMhBdOyL8hSYo/Z4nRD6O5OvrydjXWyvd8W7QOTftBOKSSn3PH3` is signing the release.
That user signs the `asfaload.index.json` file, and puts its signature under the release directory on the mirror in the subdirectory `signature`
in a file named to the base64 encoding of the public key used: `signatures/UldUc2JSTWhCZE95TDhoU1lvL1o0blJENk81T3ZyeWRqWFd5dmQ4VzdRT1RmdEJPS1NTbjNQSDMK`.

# Downloading a file

The downloader identifies the current signers on the mirror in the release directory.
It looks at the threshold and iterates over the authorised signers, looking for each public key for the signature file (see naming convention above).
If a signature file is found, it is validated. If it is valid the count of signature is incremented.
When the threshold is reached by the count of signatures, the iteration ends and the release is deemed signed and authenticated. Further
processing of the download can proceed.
