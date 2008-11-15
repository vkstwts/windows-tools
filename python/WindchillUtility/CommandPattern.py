class Dispatcher:

    def do_get(self):
        print 'Get'

    def do_put(self):
        print 'Put'
        
    def do_error(self):
        print 'Error'

    def dispatch(self, command):
        mname = 'do_' + command
        if hasattr(self, mname):
            method = getattr(self, mname)
            method()
        else:
            self.error()

d= Dispatcher();
d.dispatch('put');
d.dispatch('get');
d.dispatch('error');