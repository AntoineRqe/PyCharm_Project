# encoding utf-8

from toolbox import *
import os


class Maps:
    """
    Class to identify the map.
    """
    def __init__(self):
        self.drawings = dict()
        self.names = list()

    def load_map(self, path_to_maps):
        """
        Load all map available in the folder
        """

        names_list = find_file_extension(path_to_maps, "txt")
        for name in names_list:
            if not self.has_map_good_format(path_to_maps, name):
                continue

            self.names.append(remove_file_extension(name))
            file = os.path.join(path_to_maps, name)
            name_list = list()

            with open(file) as f:
                for line in f:
                    line = line.rstrip()
                    name_list.append(line)

            self.drawings[remove_file_extension(name)] = name_list

    @staticmethod
    def has_map_good_format(path_to_maps, map__name):
        """
        Check if the given text file has good format for the game
        :param map_full_name: name of the file containing the map
        :param path_to_maps: path to find all maps
        :return: map is formed of a list of string
        """

        map_lines = list()
        file = os.path.join(path_to_maps, map__name)

        if not os.path.isfile(file) or os.path.getsize(file) == 0:
            return False

        return True

