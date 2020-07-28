CLASSES  = \
	Checker.java InterSucc.java AbsEntry.java AbsFunction.java

JFLAGS = -classpath .
JARFLAGS = cvfm

JAVAC    = javac
JAR      = jar

jars: classes
	$(JAR) $(JARFLAGS) Checker.jar Checker.MF *.class

.SUFFIXES: .java .class

.java.class:
	$(JAVAC) $(JFLAGS) $*.java

default: classes

classes: $(CLASSES:.java=.class)

clean:
	find -name '*.class' |xargs rm -rf
