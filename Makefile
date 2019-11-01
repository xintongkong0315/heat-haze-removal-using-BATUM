SHELL := /bin/bash

TARGET=/tmp/public-repo

clean:
	find . -name '*~' -exec rm {} \;

distclean: clean
	rm -rf $(TARGET)

build-public-repo:
	@rm -rf $(TARGET)
	@git clone https://cdeledalle@bitbucket.org/cdeledalle/batud.git $(TARGET)
	@public_file() {					\
	   if ! git check-ignore -q "$$1" && \
             [[ $$1 != *private* ]] && \
             [[ $$1 != ./$(TARGET) ]] && \
             [[ $$1 != ./old* ]] && \
             [[ $$1 != Makefile ]] ; then \
	       echo "Copy $$1"; \
	       mkdir -p $(TARGET)/$$(dirname "$$1"); \
	       cp -f "$$1" $(TARGET)/$$1; \
	       cd $(TARGET); \
	       git add "$$1"; \
               cd -; \
          fi; \
	}; export -f public_file; \
	find . -type f -exec bash -c 'public_file "$$0"' {} \;

