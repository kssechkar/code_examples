#include "bmp_process.h"
#include "controller/controller.h"

int main(int argc, char** argv) {
    Controller controller(argc, argv);
    if (controller.GetInputStream().good() && controller.GetOutputStream().good()) {
        Image image = ReadBMPFile(controller.GetInputStream());

        image = controller.ApplyFilters(image);

        WriteBMPFile(controller.GetOutputStream(), image);
    }

}
