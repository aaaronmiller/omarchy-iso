"""stage_migration_kit: stages the baked-in kit on Surface targets only, and never fails the install."""
import ast
import shutil
import stat
import tempfile
import types
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
source = ROOT / "configs/airootfs/usr/share/omarchy-iso/orchestrator/phases_impl.py"
text = source.read_text()
tree = ast.parse(text)
wanted_assign = {"MIGRATION_KIT_SRC", "MIGRATION_AUTOSTART"}
body = [n for n in tree.body
        if (isinstance(n, ast.Assign) and getattr(n.targets[0], "id", None) in wanted_assign)
        or (isinstance(n, ast.FunctionDef) and n.name == "stage_migration_kit")]
module = ast.Module(body=body, type_ignores=[])
code = compile(module, str(source), "exec")
# The function does `from .context import _is_surface`; the test injects its own.
code_text = ast.unparse(module).replace("from .context import _is_surface", "pass")


def load(is_surface, kit_src):
    messages = []
    ns = {"Path": Path, "shutil": shutil, "info": messages.append, "InstallContext": object,
          "_is_surface": lambda: is_surface}
    exec(compile(code_text, str(source), "exec"), ns)
    ns["MIGRATION_KIT_SRC"] = kit_src
    return ns, messages


def make_kit(root):
    kit = root / "kit"
    (kit / "scripts").mkdir(parents=True)
    (kit / "scripts" / "firstlogin.sh").write_text("#!/bin/sh\n")
    (kit / "scripts" / "00-postinstall.sh").write_text("#!/bin/sh\n")
    (kit / "scripts" / "00-postinstall.sh").chmod(0o644)
    (kit / "link").symlink_to("scripts/firstlogin.sh")
    return kit


class StageMigrationKitTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        self.target = self.tmp / "mnt"
        self.target.mkdir()
        self.ctx = types.SimpleNamespace(target=self.target)

    def test_stages_kit_launcher_and_autostart_on_surface(self):
        ns, _ = load(True, make_kit(self.tmp))
        ns["stage_migration_kit"](self.ctx)
        kit = self.target / "usr/share/omarchy-migration-kit"
        self.assertTrue((kit / "scripts/00-postinstall.sh").stat().st_mode & stat.S_IXUSR)
        self.assertTrue((kit / "link").is_symlink())
        launcher = self.target / "usr/local/bin/omarchy-migration-firstlogin"
        self.assertTrue(launcher.stat().st_mode & stat.S_IXUSR)
        desktop = (self.target / "etc/xdg/autostart/omarchy-migration-firstlogin.desktop").read_text()
        self.assertIn("Exec=/usr/local/bin/omarchy-migration-firstlogin", desktop)
        self.assertTrue((self.target / "var/lib/omarchy/migrations/1789325478").exists())

    def test_does_nothing_on_other_hardware(self):
        ns, _ = load(False, make_kit(self.tmp))
        ns["stage_migration_kit"](self.ctx)
        self.assertEqual(list(self.target.iterdir()), [])

    def test_does_nothing_without_a_baked_in_kit(self):
        ns, _ = load(True, self.tmp / "missing")
        ns["stage_migration_kit"](self.ctx)
        self.assertEqual(list(self.target.iterdir()), [])

    def test_restaging_replaces_the_old_copy(self):
        ns, _ = load(True, make_kit(self.tmp))
        ns["stage_migration_kit"](self.ctx)
        stale = self.target / "usr/share/omarchy-migration-kit/stale"
        stale.write_text("x")
        ns["stage_migration_kit"](self.ctx)
        self.assertFalse(stale.exists())

    def test_failure_is_reported_not_raised(self):
        kit = make_kit(self.tmp)
        (kit / "scripts" / "firstlogin.sh").unlink()  # launcher copy will fail
        ns, messages = load(True, kit)
        ns["stage_migration_kit"](self.ctx)
        self.assertTrue(any("skipped" in m for m in messages))


if __name__ == "__main__":
    unittest.main()
