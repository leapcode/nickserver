Testing Strategy
================

Dispatcher Integration Tests
----------------------------

The dispatcher hands the requests to different handlers and responds with the
first response it gets. We test the integration between the dispatcher and the
handlers. We do so by confirming that a given query is handed to the right
source in the expected manner.
In order to do so we mock the sources. We also keep the server out of the loop.
This way these tests should be deterministic and fast.

Remote Tests
------------

Test the interaction of our sources with remote services. These tests make
use of the real network. Therefore they are prone to network errors and non-
deterministic server responses. With the expected result they will pass. Known
failure cases should be covered in a unit test and lead to skipping the remote
test. Unexpected remote behaviour should cause an Error. If you observe such an
error:
 * create a unit test for the source that triggers the same behaviour
 * handle it appropriately in the source
 * change the integration test to skip if the same behaviour happens again.


Source Unit Tests
-----------------

As described above these should cover all possible network issues and make sure
we return the right response in these cases.
We can trigger the observed remote behaviour by mocking the adapter and thus
make it deterministic.
