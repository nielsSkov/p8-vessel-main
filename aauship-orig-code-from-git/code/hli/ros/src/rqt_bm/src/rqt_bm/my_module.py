#!/usr/bin/env python
import os
import rospy

from qt_gui.plugin import Plugin
from python_qt_binding import loadUi
from python_qt_binding.QtCore import Qt, QTimer, Slot
from python_qt_binding.QtGui import QWidget
from python_qt_binding.QtGui import *

from aauship.msg import *

from std_msgs.msg import String

class MyPlugin(Plugin):

    def __init__(self, context):
        super(MyPlugin, self).__init__(context)
        # Give QObjects reasonable names
        self.setObjectName('MyPlugin')

        # Process standalone plugin command-line arguments
        from argparse import ArgumentParser
        parser = ArgumentParser()
        # Add argument(s) to the parser.
        parser.add_argument("-q", "--quiet", action="store_true",
                      dest="quiet",
                      help="Put plugin in silent mode")
        args, unknowns = parser.parse_known_args(context.argv())

        # Create QWidget
        self._widget = QWidget()
        # Get path to UI file which is a sibling of this file
        # in this example the .ui and .py file are in the same folder
        ui_file = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                'BatteryMonitor.ui')
        # Extend the widget with all attributes and children from UI file
        loadUi(ui_file, self._widget)
        # Give QObjects reasonable names
        self._widget.setObjectName('BatteryMonitorUi')
        # Show _widget.windowTitle on left-top of each plugin (when 
        # it's set in _widget). This is useful when you open multiple 
        # plugins at once. Also if you open multiple instances of your 
        # plugin at once, these lines add number to make it easy to 
        # tell from pane to pane.
        if context.serial_number() > 1:
            self._widget.setWindowTitle(self._widget.windowTitle() + (' (%d)' % context.serial_number()))
        # Add widget to the user interface
        context.add_widget(self._widget)


        # Catch keypresses (shortcuts)
        #self.shortcut_w = QShortcut(QKeySequence(Qt.Key_W), self._widget)
        #self.shortcut_w.setContext(Qt.ApplicationShortcut)
        #self.shortcut_w.activated.connect(self._cb2)

        # Catch change events on widgets
        #self._widget.name.valueChanged.connect(self.foo)
        
        # Push buttons
        self._widget.pushButtonSample.pressed.connect(self._sample)
        self._widget.checkBox.pressed.connect(self._pooling)

        #4.20v = 100%
        #4.03v = 76%
        #3.86v = 52%
        #3.83v = 42%
        #3.79v = 30%
        #3.70v = 11%
        #3.6?v = 0%

        # Initialize variables
        self.desc = ''
        self.now = rospy.get_time()
#        self._widget.labelTimestamp.setText(str(self.now))
        self.running = False

        # Topic stuff
        self._sub = rospy.Subscriber( "bm", BatteryMonitor, self._update)
        self._pub = rospy.Publisher( "lli_input", LLIinput, queue_size=1)
       
        # Open log file
#        self.log = open("logs/bm" + str(rospy.get_time()) + ".log", 'w', 1)


    def _get_time(self):
        self.now = rospy.get_time()
#        self._widget.labelTimestamp.setText(str(self.now))
        return self.now

    def _update(self, data):
        print(data)
        self._widget.progressBar11.setValue(data.bank1[0])
        self._widget.progressBar12.setValue(data.bank1[1])
        self._widget.progressBar13.setValue(data.bank1[2])
        self._widget.progressBar14.setValue(data.bank1[3])
        self._widget.progressBar21.setValue(data.bank2[0])
        self._widget.progressBar22.setValue(data.bank2[1])
        self._widget.progressBar23.setValue(data.bank2[2])
        self._widget.progressBar24.setValue(data.bank2[3])
  
    def _pooling(self):

        if self._widget.checkBox.checkState():
            print("Pooling deactivated")
            self._widget.checkBox.setText("Enable pooling")
        else:
            print("Pooling activated")
            self._widget.checkBox.setText("Not implemented!")

    def _sample(self):
        print("Sampled")
        # Publish 24 00 00 0C 13 37 to the lli-input topic
        # This requests battery monitor samples
        self._pub.publish(0, 12, 0, 0.0)

    def shutdown_plugin(self):
        # TODO unregister all publishers here
        if self._pub is not None:
            self._pub.unregister()
            self._pub = None
        if self._sub is not None:
            self._sub.unregister()
            self._sub = None
        #self.log.close()
        pass

    def save_settings(self, plugin_settings, instance_settings):
        # TODO save intrinsic configuration, usually using:
        # instance_settings.set_value(k, v)
        pass

    def restore_settings(self, plugin_settings, instance_settings):
        # TODO restore intrinsic configuration, usually using:
        # v = instance_settings.value(k)
        pass

