#!/usr/bin/python3
import sys
import argparse
import subprocess as sp

def parse_urls_dict(overlay_file):
    overlay = map(str.strip, overlay_file.readlines())
    urls_dict = {}
    for line in filter(lambda l: l.startswith("##"), overlay):
        ls = line.split()
        pname = ls[1]
        url = " ".join(ls[3:])
        urls_dict[pname] = url
    return urls_dict

def override_string(pname: str, version: str, url: str, sha256: str):  
    return f"""\
  {pname}_{version.replace('.', '_')} = {pname}.overrideAttrs (old: rec {{
    version = \"{version}\";
    src = prev.fetchurl {{
      url = {url};
      sha256 = \"{sha256}\";
    }};
  }});"""

def get_url(interp_url: str, version: str):
    cmd = f"nix eval --impure --expr 'let version=\"{version}\"; in with (import <nixpkgs/lib>).versions; \"{interp_url}\"'"
    result = sp.run(cmd, capture_output=True, shell=True, encoding='utf-8')
    return result.stdout.strip()

def get_sha256(url: str):
    cmd = f"nix-prefetch-url {url}"
    try:
        result = sp.run(cmd, capture_output=True, shell=True, encoding='utf-8', check=True)
    except sp.SubprocessError:
        sys.exit("error: version does not exist")
    return result.stdout.strip()

def main():
    ap = argparse.ArgumentParser(description="add automated overrides to overlay.nix")
    ap.add_argument("pname", type=str, help="name of the package")
    ap.add_argument("version", type=str, help="version to be added")

    args = ap.parse_args()
    pname, version = args.pname, args.version

    with open("overlay.nix", "r") as overlay_file:
        urls_dict = parse_urls_dict(overlay_file)
    
    if args.pname not in urls_dict:
        sys.exit("error: package is not available")
        
    interp_url = urls_dict[pname]

    url = get_url(interp_url, version)
    sha256 = get_sha256(url)

    override_str = override_string(pname, version, interp_url, sha256)
    print(override_str)

if __name__ == "__main__":
    main()
