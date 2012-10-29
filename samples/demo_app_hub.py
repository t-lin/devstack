import logging
import struct
import os

from ryu.app.rest_nw_id import NW_ID_UNKNOWN, NW_ID_EXTERNAL
from ryu.base import app_manager
from ryu.exception import MacAddressDuplicated
from ryu.exception import PortUnknown
from ryu.controller import dpset
from ryu.controller import mac_to_network
from ryu.controller import mac_to_port
from ryu.controller import network
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER
from ryu.controller.handler import CONFIG_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import nx_match
from ryu.lib.mac import haddr_to_str
from ryu.lib import mac


LOG = logging.getLogger('ryu.demo.demo_app')

class DemoApp(object):
    def __init__(self, appObjs):
        self.mac2port = appObjs['mac2port']

    def _drop_packet(self, msg):
        LOG.info("Dropping packet")
        datapath = msg.datapath
        datapath.send_packet_out(msg.buffer_id, msg.in_port, [])

    def handle_packet_in(self, ev):
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto

        dst, src, _eth_type = struct.unpack_from('!6s6sH', buffer(msg.data), 0)

        dpid = datapath.id
        LOG.info("Src MAC: %s; Dest MAC: %s", haddr_to_str(src), haddr_to_str(dst))

        actions = [datapath.ofproto_parser.OFPActionOutput(ofproto.OFPP_FLOOD)]
        LOG.info("Input port: %s; Output port: %s", msg.in_port, ofproto.OFPP_FLOOD)

        rule = nx_match.ClsRule()
        rule.set_in_port(msg.in_port)
        rule.set_dl_dst(dst)
        rule.set_dl_src(src)
        rule.set_nw_dscp(0)
        datapath.send_flow_mod(
            rule=rule, cookie=0, command=ofproto.OFPFC_ADD,
            idle_timeout=0, hard_timeout=0,
            priority=ofproto.OFP_DEFAULT_PRIORITY,
            flags=ofproto.OFPFF_SEND_FLOW_REM, actions=actions)

        datapath.send_packet_out(msg.buffer_id, msg.in_port, actions)



