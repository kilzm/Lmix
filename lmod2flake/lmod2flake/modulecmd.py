from lmod.module import Module
import subprocess

class ModuleCmd(Module):
    def list(self):
        cmd = "bash -l -c 'module -t list'"

        ret = subprocess.run(
            cmd,
            shell=True,
            encoding="utf-8",
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        if ret.stdout.startswith("No modules loaded"):
            return []
        
        return ret.stdout.split()
