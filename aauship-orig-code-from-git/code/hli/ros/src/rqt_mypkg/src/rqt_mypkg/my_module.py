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
        ui_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'MyPlugin.ui')
        # Extend the widget with all attributes and children from UI file
        loadUi(ui_file, self._widget)
        # Give QObjects reasonable names
        self._widget.setObjectName('MyPluginUi')
        # Show _widget.windowTitle on left-top of each plugin (when 
        # it's set in _widget). This is useful when you open multiple 
        # plugins at once. Also if you open multiple instances of your 
        # plugin at once, these lines add number to make it easy to 
        # tell from pane to pane.
        if context.serial_number() > 1:
            self._widget.setWindowTitle(self._widget.windowTitle() + (' (%d)' % context.serial_number()))
        # Add widget to the user interface
        context.add_widget(self._widget)

        self._sub_attitude = rospy.Subscriber( "attitude", Attitude,
                self._update_attitude)
        self._sub_gps = rospy.Subscriber( "gps1", GPS,
                self._update_gps)
        self._pub_pid = rospy.Publisher( "testPID", controlTest)

        # Catch keypresses (shortcuts)
        self.shortcut_w = QShortcut(QKeySequence(Qt.Key_W), self._widget)
        self.shortcut_w.setContext(Qt.ApplicationShortcut)
        self.shortcut_w.activated.connect(self._cb2)

        # Catch change events on widgets
        #self._widget.name.valueChanged.connect(self.foo)
        self._widget.SpinBoxSurgeP.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSurgeI.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSurgeD.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSwayP.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSwayI.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSwayD.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxYawP.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxYawI.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxYawD.valueChanged.connect(self._update_pid_values)

        self._widget.SpinBoxSurgeVel.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSurgeAng.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSwayVel.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxSwayAng.valueChanged.connect(self._update_pid_values)
        self._widget.SpinBoxYawAngVel.valueChanged.connect(self._update_pid_values)

        self._widget.groupBoxAutopilot.toggled.connect(self._enable_autopilot)
        self._widget.radioButtonSurgeTest.toggled.connect(self._update_pid_values)
        self._widget.radioButtonSwayTest.toggled.connect(self._update_pid_values)
        self._widget.radioButtonYawTest.toggled.connect(self._update_pid_values)

        print self._widget.SpinBoxSurgeAng.maximum()
        self._widget.SpinBoxSurgeAng.setMinimum(-100)

        self.controllerData = controlTest()
    
    def _cb2(self):
        self._widget.label.setText('meh')

    def _update_attitude(self, data):
        self._widget.labelPitch.setText(str(data.pitch))
        self._widget.labelRoll.setText(str(data.roll))
        self._widget.labelYaw.setText(str(data.yaw))

    def _update_gps(self, data):
        self._widget.labelGPSlat.setText(str(data.latitude))
        self._widget.labelGPSlon.setText(str(data.longitude))
        self._widget.labelGPSHeading.setText(str(data.true_heading))
        self._widget.labelGPSSpeed.setText(str(data.speed_over_ground))

    def _update_pid_values(self):
        print "dd"
        print self.controllerData.pid
        print "ff"
        self._pub_pid.publish(self.controllerData)
        if self._widget.radioButtonSurgeTest.isChecked():
            print "Surge controller selected"
            self.controllerData.pid.Kp = self._widget.SpinBoxSurgeP.value()
            self.controllerData.pid.Ki = self._widget.SpinBoxSurgeI.value()
            self.controllerData.pid.Kd = self._widget.SpinBoxSurgeD.value()
            self.controllerData.setpoints.cmd_vel = self._widget.SpinBoxSurgeVel.value()
            self.controllerData.setpoints.cmd_ang = self._widget.SpinBoxSurgeAng.value()
            self.controllerData.setpoints.controller_type = 1
        elif self._widget.radioButtonSwayTest.isChecked():
            print "Sway controller selected"
            self.controllerData.pid.Kp = self._widget.SpinBoxSwayP.value()
            self.controllerData.pid.Ki = self._widget.SpinBoxSwayI.value()
            self.controllerData.pid.Kd = self._widget.SpinBoxSwayD.value()
            self.controllerData.setpoints.cmd_vel = self._widget.SpinBoxSwayVel.value()
            self.controllerData.setpoints.cmd_ang = self._widget.SpinBoxSwayAng.value()
            self.controllerData.setpoints.controller_type = 2
        elif self._widget.radioButtonYawTest.isChecked():
            print "Yaw controller selected"
            self.controllerData.pid.Kp = self._widget.SpinBoxYawP.value()
            self.controllerData.pid.Ki = self._widget.SpinBoxYawI.value()
            self.controllerData.pid.Kd = self._widget.SpinBoxYawD.value()
            self.controllerData.setpoints.cmd_angvel = self._widget.SpinBoxYawAngVel.value()
            self.controllerData.setpoints.controller_type = 3
        self._pub_pid.publish(self.controllerData)

    def _enable_autopilot(self):
        if self._widget.groupBoxAutopilot.isChecked():
            print "Autopilot Enabled"
            self._widget.labelControlStatus.setStyleSheet(
                    "background-color: rgb(0, 255, 0);")
            self._widget.labelControlStatus.setText('CONTROL ENABLED') 
        else:
            print "Autopilot Disabled"
            self._widget.labelControlStatus.setStyleSheet(
                    "background-color: rgb(171, 171, 171);")
            self._widget.labelControlStatus.setText('CONTROL DISABLED') 

    def foo(self):
        print "Foo, this is a dummy function"

    def shutdown_plugin(self):
        # TODO unregister all publishers here
        if self._pub_pid is not None:
            self._pub_pid.unregister()
            self._pub_pid = None
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
