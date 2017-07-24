Integration tests for clients of remote services
================================================

The tests in this directory are integration test with remote services.
However we aims at testing the client side of the equation as that is
what we control here.

So unexpected server behavious should *crash* the test if we are not
dealing with it properly yet and have no unit test for it.

Server responses that we do not expect but handle in the code and test
in unit tests make the test *skip*.

The Behaviour we would normally expect should make the test *pass*
