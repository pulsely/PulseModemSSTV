//
//  TestView.swift
//  SSTVGenerator
//
//  Created by Kenneth Lo on 12/17/22.
//

import SwiftUI
import CoreData

import Python
import PythonKit

struct TestView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var msg = ""
    @State var webserver:PythonObject?
    @State var longjob:PythonObject?
    @State var sstv:PythonObject?

    @State var workItem: DispatchWorkItem?
    @State var blockOperation:BlockOperation?
    @State var queue:OperationQueue?
    @State var serverProcess:PythonObject?
    
    func initializePython() {
        // we now have a Python interpreter ready to be used
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }
        
        guard let sitepackages = Bundle.main.path(forResource: "venv/lib/python3.10/site-packages", ofType: nil) else { return }

        guard let src = Bundle.main.path(forResource: "src", ofType: nil) else { return }
        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath)", 1)
        Py_Initialize()
        
        let sys = Python.import("sys")
        sys.path.append(sitepackages)
        sys.path.append(src)

        print("Python Version: \(sys.version_info.major).\(sys.version_info.minor)")
        print("Python Encoding: \(sys.getdefaultencoding().upper())")
        print("Python Path: \(sys.path)")
        
    }
    
    func startSSTVConversion() {
        self.sstv = Python.import("sstv")
        self.sstv?.sample_conversion()
    }
    
    func startLongJob() {
        debugPrint(">> startLongJob()")
        var longjob = Python.import("longjob")
        var pid = longjob.startFork()
        debugPrint(">> pid is: \(pid)")
        //self.serverProcess = self.webserver?.startProcess()

//        self.blockOperation = BlockOperation {
//            self.longjob = Python.import("longjob")
//            self.serverProcess = self.webserver?.startProcess()
//            //            self.serverProcess?.start()
//
//            //            debugPrint( "\(self.serverProcess!)" )
//            //            self.serverProcess?.terminate()
//            //            self.serverProcess?.join()
//
//
//        }
//        self.blockOperation?.completionBlock = {
//        self.blockOperation?.completionBlock = {
//            print(">> startServer completionBlock done")
//        }
//
//        self.queue = OperationQueue()
//        queue!.addOperation(self.blockOperation!)

    }
    
    func stopLongJob() {
        debugPrint(">> stopLongJob()")
        debugPrint(">> longjob: \(longjob)")
    }
    
    func startServer() {
        var boto3 = Python.import("boto3")
        debugPrint( boto3.__version__ )
        let np = Python.import("numpy")
        print(np)
        let zeros = np.ones([2, 3])
        print(zeros)

        //        self.workItem = DispatchWorkItem {
        //            DispatchQueue.global().async {
        //                self.webserver = Python.import("webserver")
        //                self.webserver?.startProcess()
        //            }
        //        }
        //        //DispatchQueue.global().async(execute: self.workItem!)
        //        self.workItem?.perform()
        
        
        self.blockOperation = BlockOperation {
            self.webserver = Python.import("webserver")
            self.serverProcess = self.webserver?.startProcess()
            //            self.serverProcess?.start()
            
            //            debugPrint( "\(self.serverProcess!)" )
            //            self.serverProcess?.terminate()
            //            self.serverProcess?.join()
            
            
        }
        self.blockOperation?.completionBlock = {
            print(">> startServer completionBlock done")
        }
        
        self.queue = OperationQueue()
        queue!.addOperation(self.blockOperation!)
        
    }
    
    func stopServer() {
        debugPrint( "\(self.serverProcess!)" )
        self.serverProcess?.terminate()
        self.serverProcess?.join()
        
        self.queue?.cancelAllOperations()
        self.blockOperation?.cancel()
        
        //self.queue = nil
        //self.blockOperation = nil
    }
    
    func test() {
        var math = Python.import("math") // verifies `lib-dynload` is found and signed successfully
        var acos = math.acos( 0.123 )
        debugPrint( acos )
        msg = "\(acos)"
        
        var pysstv = Python.import("pysstv") // verifies `lib-dynload` is found and signed successfully
        msg = "\(pysstv)"
        debugPrint( pysstv )
        
        var helloworld = Python.import("helloworld")
        var value = helloworld.test("Mac")
        msg = "\(value)"
    }
    
    
    var body: some View {
        VStack {
            
            Button(action: {
                self.startSSTVConversion()
            }) {
                Text("SSTV Conversion")
            }.padding(.vertical)

            
            Divider()
            
            Button(action: {
                self.startServer()
            }) {
                Text("Start Webserver")
            }.padding(.vertical)
            
            Button(action: {
                self.stopServer()
            }) {
                Text("Stop Webserver")
            }.padding(.vertical)
            Divider()
            
            Button(action: {
                self.startLongJob()
            }) {
                Text("Start Long Job")
            }.padding(.vertical)
            
            Button(action: {
                self.stopLongJob()
            }) {
                Text("Stop Long Job")
            }.padding(.vertical)
            
            
            Spacer()
        }.task {
            self.initializePython()
            
            //self.startServer()
            
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
