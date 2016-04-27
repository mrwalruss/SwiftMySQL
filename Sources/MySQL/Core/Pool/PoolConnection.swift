import Foundation

public class PoolConnection : Connection {
    let expire : NSDate;
    let poolManager : Pool;

    init(config : ConnectionConfig, poolManager : Pool) {
        self.expire = NSDate().addingTimeInterval(60);
        self.poolManager = poolManager;
        super.init(config : config);
    }

    deinit {
        close();
        self.poolManager.poolClosed();
    }

    func isLife() -> Bool {
        if (self.state == .DISCONNECTED) {
            return false;
        }

        let compare = NSDate().compare(self.expire);
        let result : Bool;
#if os(Linux)
        result = (compare == .OrderedAscending);
#elseif os(OSX)
        result = (compare == .orderedAscending);
#endif

        if ((!result) || (!self.ping())) {
            self.close();
        }

        return result;
    }
}