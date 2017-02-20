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
        print "fooooo"
        if not args.quiet:
            print 'arguments: ', args
            print 'unknowns: ', unknowns
        print "foooffffff"
        # Create QWidget
        self._widget = QWidget()
        # Get path to UI file which is a sibling of this file
        # in this example the .ui and .py file are in the same folder
        ui_file = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                'LogAnnotate.ui')
        # Extend the widget with all attributes and children from UI file
        loadUi(ui_file, self._widget)
        # Give QObjects reasonable names
        self._widget.setObjectName('LogAnnotateUi')
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
        self._widget.pushButtonStart.pressed.connect(self._start)
        self._widget.pushButtonStop.pressed.connect(self._stop)

        # Initialize variables
        self.desc = ''
        self.now = rospy.get_time()
        self._widget.labelTimestamp.setText(str(self.now))
        self.starttime = 0.0
        self.stoptime = 0.0
        self.running = False
       
        # Open log file
        self.log = open("logs/annotate" + str(rospy.get_time()) + ".log", 'w', 1)

    def _get_time(self):
        self.now = rospy.get_time()
        self._widget.labelTimestamp.setText(str(self.now))
        return self.now
    
    def _start(self):
        print("Started")
        if not (self.running):
            self.starttime = self._get_time()
            self.running = True
        self._widget.lineEditDescription.setStyleSheet(
                "background-color: rgb(255, 0, 0);")

    def _stop(self):
        print("Stopped")
        self.stoptime = self._get_time()
        self._widget.lineEditDescription.setStyleSheet(
                "background-color: rgb(0, 255, 0);")
        self.desc = self._widget.lineEditDescription.text()
        line = str(self.starttime) + ';' + str(self.stoptime) + ';' + self.desc + "\n"
        self.running = False
        print line
        self.log.write(line)
        self._widget.lineEditDescription.clear()


    def shutdown_plugin(self):
        # TODO unregister all publishers here
        #if self._pub_pid is not None:
        #    self._pub_pid.unregister()
        #    self._pub_pid = None
        self.log.close()
        pass

    def save_settings(self, plugin_settings, instance_settings):
        # TODO save intrinsic configuration, usually using:
        # instance_settings.set_value(k, v)
        pass

    def restore_settings(self, plugin_settings, instance_settings):
        # TODO restore intrinsic configuration, usually using:
        # v = instance_settings.value(k)
        pass

    #def trigger_configuration(self):
        # Comment in to signal that the plugin has a way to configure
        # This will enable a setting button (gear icon) in each dock widget title bar
        # Usually used to open a modal configuration dialog
