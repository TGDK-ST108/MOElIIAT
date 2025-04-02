from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.clock import Clock
import subprocess

class DebuggerUI(BoxLayout):
    def __init__(self, **kwargs):
        super(DebuggerUI, self).__init__(orientation='vertical', **kwargs)
        self.status_label = Label(text="Status: Idle")
        self.add_widget(self.status_label)

        self.pair_button = Button(text="Pair Wireless ADB")
        self.pair_button.bind(on_press=self.pair_device)
        self.add_widget(self.pair_button)

        self.unlock_button = Button(text="Run OEM Unlock Vortex")
        self.unlock_button.bind(on_press=self.run_unlock)
        self.add_widget(self.unlock_button)

        self.push_patch_button = Button(text="Push init_boot.img to Device")
        self.push_patch_button.bind(on_press=self.push_patch)
        self.add_widget(self.push_patch_button)

        self.pull_patch_button = Button(text="Pull patched boot.img")
        self.pull_patch_button.bind(on_press=self.pull_patch)
        self.add_widget(self.pull_patch_button)

    def run_command(self, cmd):
        try:
            output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True)
            self.status_label.text = f"Output: {output.strip()}"
        except subprocess.CalledProcessError as e:
            self.status_label.text = f"Error: {e.output.strip()}"

    def pair_device(self, instance):
        self.status_label.text = "Pairing... (run adb pair manually in terminal for now)"

    def run_unlock(self, instance):
        self.run_command("bash oem_unlock_vortex.sh")

    def push_patch(self, instance):
        self.run_command("adb push init_boot.img /sdcard/Download/")

    def pull_patch(self, instance):
        self.run_command("adb pull /sdcard/Download/magisk_patched*.img ./")

class DebuggerApp(App):
    def build(self):
        return DebuggerUI()

if __name__ == '__main__':
    DebuggerApp().run()
 

