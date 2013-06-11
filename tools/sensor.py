import sensors
import json


sensors.init()
temperature = []
try :
    for chip in sensors.iter_detected_chips():
        chip_info = dict ()
        chip_info[ 'adapter' ] = chip.adapter_name
        chip_info[ 'chip' ] = str(chip)
        feature_info = dict ()
        print '%s at %s' % (chip, chip.adapter_name)
        for feature in chip:
            feature_info[feature.label] = feature.get_value()
            print '  %s: %.2f' % (feature.label, feature.get_value())
        chip_info[ 'feature' ] = feature_info
        temperature.append(chip_info)
finally :
    sensors.cleanup()
print temperature
print json.dumps(temperature)

#sensors.init()
#try:
#    for chip in sensors.iter_detected_chips():
#        print '%s at %s' % (chip, chip.adapter_name)
#        for feature in chip:
#            print '  %s: %.2f' % (feature.label, feature.get_value())
#finally:
#    sensors.cleanup()

#print get_temperature()
