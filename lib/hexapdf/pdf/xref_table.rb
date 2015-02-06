# -*- encoding: utf-8 -*-

require 'hexapdf/pdf/utils/object_hash'

module HexaPDF
  module PDF

    # Manages the indirect objects of one cross-reference table or stream.
    #
    # A PDF file can have more than one cross-reference table or stream which are all daisy-chained
    # together. This allows later tables to override entries in prior ones. This is automatically
    # and transparently done by HexaPDF.
    #
    # Note that a cross-reference table may contain a single object number only once.
    #
    # See: Revision
    # See: PDF1.7 s7.5.4, s7.5.8
    class XRefTable < Utils::ObjectHash

      # One entry of a cross-reference section or stream.
      #
      # An entry has the attributes +type+, +oid+, +gen+, +pos+ and +objstm+ and can be created like
      # this:
      #
      #   Entry.new(type, oid, gen, pos, objstm)   -> entry
      #
      # The +type+ attribute can be:
      #
      # :free:: Denotes a free entry.
      #
      # :in_use:: A used entry that resides in the body of the PDF file. The +pos+ attribute defines
      #           the position in the file at which the object can be found.
      #
      # :compressed:: A used entry that resides in an object stream. The +objstm+ attribute contains
      #               the reference to the object stream in which the object can be found and the
      #               +pos+ attribute contains the index into the object stream.
      #
      #               Objects in an object stream always have a generation number of 0!
      #
      # See: PDF1.7 s7.5.4, s7.5.8
      Entry = Struct.new(:type, :oid, :gen, :pos, :objstm) do

        def free?
          type == :free
        end

        def in_use?
          type == :in_use
        end

        def compressed?
          type == :compressed
        end

      end

      # Creates an in-use cross-reference entry. See Entry for details on the parameters.
      def self.in_use_entry(oid, gen, pos)
        Entry.new(:in_use, oid, gen, pos)
      end

      # Creates a free cross-reference entry. See Entry for details on the parameters.
      def self.free_entry(oid, gen)
        Entry.new(:free, oid, gen)
      end

      # Creates a compressed cross-reference entry. See Entry for details on the parameters.
      def self.compressed_entry(oid, objstm, pos)
        Entry.new(:compressed, oid, 0, pos, objstm)
      end

      # Make the assignment method private so that only the provided convenience methods can be
      # used.
      private :"[]="

      # Adds an in-use entry to the cross-reference table.
      def add_in_use_entry(oid, gen, pos)
        self[oid, gen] = self.class.in_use_entry(oid, gen, pos)
      end

      # Adds a free entry to the cross-reference table.
      def add_free_entry(oid, gen)
        self[oid, gen] = self.class.free_entry(oid, gen)
      end

      # Adds a compressed entry to the cross-reference section.
      def add_compressed_entry(oid, objstm, pos)
        self[oid, 0] = self.class.compressed_entry(oid, objstm, pos)
      end

    end

  end
end
