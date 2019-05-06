package zynq

import chisel3._
import freechips.rocketchip.config.{Parameters, Field}
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.util.DontTouch
import testchipip._

case object ZynqAdapterBase extends Field[BigInt]

class Top(implicit val p: Parameters) extends Module {
  val address = p(ZynqAdapterBase)
  val config = p(ExtIn)
  val target = Module(LazyModule(new FPGAZynqTop).module)
  val adapter = Module(LazyModule(new ZynqAdapter(address, config)).module)

  require(target.mem_axi4.size == 1)

  val io = IO(new Bundle {
    val ps_axi_slave = Flipped(adapter.axi.cloneType)
    val mem_axi = target.mem_axi4.head.cloneType
    val mmio_axi = target.mmio_axi4.head.cloneType
    val interrupts = Input(UInt(2.W))
  })

  io.mem_axi <> target.mem_axi4.head
  io.mmio_axi <> target.mmio_axi4.head
  target.interrupts := io.interrupts
  adapter.axi <> io.ps_axi_slave
  adapter.io.serial <> target.serial
  adapter.io.bdev <> target.bdev

  target.debug := DontCare
  // target.tieOffInterrupts()
  target.dontTouchPorts()
  target.reset := adapter.io.sys_reset
}

class FPGAZynqTop(implicit p: Parameters) extends RocketSubsystem
    with HasMasterAXI4MemPort
    with HasMasterAXI4MMIOPort
    with HasSystemErrorSlave
    with HasPeripheryBootROM
    with HasAsyncExtInterrupts
    with HasNoDebug
    with HasPeripherySerial
    with HasPeripheryBlockDevice {
  override lazy val module = new FPGAZynqTopModule(this)
}

class FPGAZynqTopModule(outer: FPGAZynqTop) extends RocketSubsystemModuleImp(outer)
    with HasRTCModuleImp
    with HasMasterAXI4MemPortModuleImp
    with HasMasterAXI4MMIOPortModuleImp
    with HasPeripheryBootROMModuleImp
    with HasExtInterruptsModuleImp
    with HasNoDebugModuleImp
    with HasPeripherySerialModuleImp
    with HasPeripheryBlockDeviceModuleImp
    with DontTouch
